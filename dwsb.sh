#!/bin/bash

# Scroll to line 978 to skip functions definition.

####################################################################################################################################################
####################################################################################################################################################
####################################################################################################################################################

setDefaultFlags() {
    # set default flags
    saveOld=false;
    ignoreOld=false;
    updateOld=false;

    showAllMessages=false;
    strictMode=false;

    return 0;
}

setSystemVariables() {
    # set colors
    CE='\e[33m'; # Error Message Color
    NC='\e[39m'; # Default Text Color
    AC='\e[92m'; # Available Option, Light Green

    script="$(readlink --canonicalize-existing "$0")";
    scriptPath="$(dirname "$script")";

    # set log file name
    logDirectory="$scriptPath/";
    logFileName='dwsb.log';
    logFile="${logDirectory}${logFileName}";

    # reset log file
    echo -n | tee "$logFile";

    return 0;
}

setWebsiteVariables() {
    # set values for validation
    availableWebsites=('kic' 'dlsg' 'imageaccess');
    availableBranches=('www-review' 'www-live');

    # set repository url
    repositoryKic='git@repo.ted-kteam.com:Kic/KIC-Website.git';
    repositoryDlsg='git@repo.ted-kteam.com:DLSG/DLSG-Website.git';
    repositoryIa='git@repo.ted-kteam.com:ImageAccess/IA-Website.git';

    websiteParentLocation='/var/www/';

    # set location for resources to save
    parametersLocation='/app/config/parameters.yml';

    uploadLocation='/web/upload';
    uploadsLocation='/web/uploads';

    downloadsLocation='/web/downloads';
    downloadsSourceAbsoluteLocation='/home/bocauser/downloads';

    return 0;
}

setDescription() {
    # script title and description
    scriptTitle='DWSB.SH - Deploy Website Using Bash';
    scriptDescription='This script allows you to automatically deploy any website automatically without any interaction.';

    return 0;
}

setArguments() {
    # site command
    siteKeys='-s|--site';
    siteValues='kic|dlsg|imageaccess';
    siteDescription='Define website that will be deployed.';

    # branch command
    branchKeys='-b|--branch';
    branchValues='www-review|www-live';
    branchDescription='Define branch for repository download.';

    # help command
    helpKeys='-h|--help';
    helpDescription='Show script help with list of available commands.';

    # save old command
    saveOldKeys='--save-old';
    saveOldDescription='Do not delete old website folder during deployment. Instead it will be renamed to *.old.';

    # ignore old command
    ignoreOldKeys='--ignore-old';
    ignoreOldDescription='Allows script to ignore existing website folder. Website will be deployed from scratch. All previous data will be lost.';

    # show all messages command
    showAllMessagesKeys='--show-all-messages';
    showAllMessagesDescription='Show all messages instead of important ones only.';

    # strict mode command
    strictModeKeys='--strict-mode';
    strictModeDescription='Enables strict mode. In this mode script execution will be stopped if any error will occur.';

    # update old command
    updateOldKeys='--update-old';
    updateOldDescription='Do not redeploy whole website. Update it with the newest version instead.';

    # needed for help print
    activeModeKeys="${saveOldKeys}|${ignoreOldKeys}|${updateOldKeys}";

    return 0;
}

handleArguments() {
    # single mode restriction flag
    modeSelected=false;

    while [[ "$#" -gt 0 ]]; do

        key="$1";
        value="$2";
        match=false;

        # help command
        if [[ " ${helpKeys//|/ } " =~ " $key " ]]; then
            echo -e "\n"\
            "\t${scriptTitle}\n"\
            "\n"\
            "\t\t${scriptDescription}\n"\
            "\n"\
            "\tOptions List:\n"\
            "\n"\
            "\t\t${AC}${helpKeys}${NC} - ${helpDescription}\n"\
            "\n"\
            "\t\t${AC}${siteKeys}${NC} - $siteDescription Values: ${AC}${siteValues}${NC}\n"\
            "\n"\
            "\t\t${AC}${branchKeys}${NC} - $branchDescription Values: ${AC}${branchValues}${NC}\n"\
            "\n"\
            "\t\t${AC}${showAllMessagesKeys}${NC} - ${showAllMessagesDescription}\n"\
            "\n"\
            "\t\t${AC}${saveOldKeys}${NC} - ${saveOldDescription}\n"\
            "\n"\
            "\t\t${AC}${ignoreOldKeys}${NC} - ${ignoreOldDescription}\n"\
            "\n"\
            "\t\t${AC}${updateOldKeys}${NC} - ${updateOldDescription}\n"\
            "\n"\
            "\t\t${AC}${strictModeKeys}${NC} - ${strictModeDescription}\n"\
            "\n";
            exit;
        fi

        # site command
        if [[ " ${siteKeys//|/ } " =~ " $key " ]]; then

            match=true;

            if [[ ! " ${availableWebsites[*],,}" =~ "${value,,}" ]]; then
                echo -e "\t${CE}ERROR! Incorrect ${AC}website${CE} option is defined. Use ${AC}${siteValues}${CE} option to define one.${NC}" | tee -a "$logFile";
                exit;
            fi

            site="${value,,}";

            shift;
            shift;
        fi

        # branch command
        if [[ " ${branchKeys//|/ } " =~ " $key " ]]; then

            match=true;

            if [[ ! " ${availableBranches[*],,}" =~ "${value,,}" ]]; then
                echo -e "\t${CE}ERROR! Incorrect ${AC}branch${CE} option is defined. Use ${AC}${branchValues}${CE} option to define one.${NC}" | tee -a "$logFile";
                exit;
            fi

            branch="${value,,}";

            shift;
            shift;
        fi

        # save old command
        if [[ " ${saveOldKeys//|/ } " =~ " $key " ]]; then

            if [[ "$modeSelected" = false ]]; then
                match=true;
                modeSelected=true;
                saveOld=true;
            else
                echo -e "\t${CE}ERROR! Multiple working modes are not supported. Exiting...${NC}" | tee -a "$logFile";
                exit;
            fi

            shift;
        fi

        # ignore old command
        if [[ " ${ignoreOldKeys//|/ } " =~ " $key " ]]; then

            if [[ "$modeSelected" = false ]]; then
                match=true;
                modeSelected=true;
                ignoreOld=true;
            else
                echo -e "\t${CE}ERROR! Multiple working modes are not supported. Exiting...${NC}" | tee -a "$logFile";
                exit;
            fi

            shift;
        fi

        # update old command
        if [[ " ${updateOldKeys//|/ } " =~ " $key " ]]; then

            if [[ "$modeSelected" = false ]]; then
                match=true;
                modeSelected=true;
                updateOld=true;
            else
                echo -e "\t${CE}ERROR! Multiple working modes are not supported. Exiting...${NC}" | tee -a "$logFile";
                exit;
            fi

            shift;
        fi

        # show all messages command
        if [[ " ${showAllMessagesKeys//|/ } " =~ " $key " ]]; then
            match=true;
            showAllMessages=true;
            shift;
        fi

        # strict mode command
        if [[ " ${strictModeKeys//|/ } " =~ " $key " ]]; then
            match=true;
            strictMode=true;
            set -e;
            set -o pipefail;
            shift;
        fi

        # quit if no match found
        if [[ ! "$match" = true ]]; then
            echo -e "\t${CE}ERROR! Unrecognized option: ${AC}\"${key}\"${CE}. Exiting...${NC}" | tee -a "$logFile";
            exit;
        fi
    done

    return 0;
}

checkRequiredParameters() {
    # check website parameter
    if [ -z "${site+x}" ]; then
        echo -e "\t${CE}ERROR! ${AC}Website${CE} is not defined. Use ${AC}${siteValues}${CE} option to define one.${NC}" | tee -a "$logFile";
        exit;
    fi

    # check branch parameter
    if [ -z "${branch+x}" ]; then
        echo -e "\t${CE}ERROR! ${AC}Branch${CE} is not defined. Use ${AC}${branchValues}${CE} option to define one.${NC}" | tee -a "$logFile";
        exit;
    fi

    # check selected mode
    if [[ "$modeSelected" = false ]]; then
        echo -e "\t${CE}ERROR! Active mode is not defined. Use ${AC}${activeModeKeys}${CE} option to define one.${NC}" | tee -a "$logFile";
        exit;
    fi

    return 0;
}

setCombinedParameters() {
    # set repository url
    case "$site" in
        kic)
            link="$repositoryKic";
        ;;

        dlsg)
            link="$repositoryDlsg";
        ;;

        imageaccess)
            link="$repositoryIa";
        ;;
    esac

    # set folder name
    folder="${branch}.${site}.com";

    # set folder website resources
    folderParametersLocation="${folder}${parametersLocation}";
    folderUploadLocation="${folder}${uploadLocation}";
    folderWebLocation=$(dirname "${folderUploadLocation}");
    folderUploadsLocation="${folder}${uploadsLocation}";

    folderAbsoluteLocation="${websiteParentLocation}${folder}";
    folderDownloadsAbsoluteLocation="${websiteParentLocation}${folder}${downloadsLocation}";

    # set base website folder name
    baseSiteBranchFolder="${site}-${branch##www-}-base";

    # set base website resources
    baseParametersLocation="${baseSiteBranchFolder}${parametersLocation}";
    baseUploadLocation="${baseSiteBranchFolder}${uploadLocation}";
    baseWebLocation=$(dirname "${baseUploadLocation}");
    baseUploadsLocation="${baseSiteBranchFolder}${uploadsLocation}";


    # show variables that were previously set
    #if [[ "${showAllMessages}" = true ]]; then
        echo -e "\tSite:\t\t\t${AC}${site}${NC}\n"\
            "\tBranch:\t\t\t${AC}${branch}${NC}\n"\
            "\tLink:\t\t\t${AC}${link}${NC}\n"\
            "\tFolder:\t\t\t${AC}${folder}${NC}\n"\
            "\tBase Folder:\t\t${AC}${baseSiteBranchFolder}${NC}\n"\
            "\n"\
            "\tSave Old Website:\t${AC}${saveOld}${NC}\n"\
            "\tIgnore Old Website:\t${AC}${ignoreOld}${NC}\n"\
            "\tUpdate Old Website:\t${AC}${updateOld}${NC}\n"\
            "\tShow All Messages:\t${AC}${showAllMessages}${NC}\n"\
            "\tStrict Mode:\t\t${AC}${strictMode}${NC}\n"\
            "\n"\
            "\tFolder Resource Locations:\n"\
            "\t\tparameters.yml:\t${AC}${folderParametersLocation}${NC}\n"\
            "\t\tweb/upload:\t${AC}${folderUploadLocation}${NC}\n"\
            "\t\tweb/uploads:\t${AC}${folderUploadsLocation}${NC}\n"\
            "\n"\
            "\tBase Resource Locations:\n"\
            "\t\tparameters.yml:\t${AC}${baseParametersLocation}${NC}\n"\
            "\t\tweb/upload:\t${AC}${baseUploadLocation}${NC}\n"\
            "\t\tweb/uploads:\t${AC}${baseUploadsLocation}${NC}\n" | tee -a "$logFile";
    #fi

    return 0;
}

makeTemporaryDirectory() {
    # go to website folder
    cd /var/www;

    ##
    ## <ATTENTION!> baseSiteBranchFolder can exist if previous deployment was failed. I should rework this code. </ATTENTION!>
    ##
    ## Since Artem and Jaroslav forced me to finish this work faster, I won't do website repair from broken state feature right now. Maybe later.
    ##

    # check base site branch folder
    if [[ -d "$baseSiteBranchFolder" ]]; then
        echo -e "\t${CE}Warning! ${AC}${baseSiteBranchFolder}${CE} folder was found. It will be removed.${NC}\n" | tee -a "$logFile";
        rm -rf "$baseSiteBranchFolder";
    else

        if [[ "$showAllMessages" = true ]]; then
            echo -e "\tINFO: ${AC}${baseSiteBranchFolder}${NC} folder was not found." | tee -a "$logFile";
        fi

    fi

    return 0;
}

checkExistingWebsiteDirectory() {
    # check existing website folder
    if [[ ! -d "$folder" ]]; then

        # save existing
        if [[ "$saveOld" = true ]] || [[ "$updateOld" = true ]]; then
            echo -e "\t${CE}ERROR! ${AC}${folder}${CE} folder was not found. Cannot save/update it.${NC}\n" | tee -a "$logFile";
            exit;
        fi
    fi

    return 0;
}

chmodExistingWebsiteDirectory() {
    if [[ -d "$folderAbsoluteLocation" ]]; then

        sudo chmod 777 "$folderAbsoluteLocation" -R;
        sudo chown www-data:www-data "$folderAbsoluteLocation" -R;

        if [[ "$showAllMessages" = true ]]; then
            echo -e "\n\tINFO: Attempted to ${AC}chmod 777 ${folderAbsoluteLocation}${NC}." | tee -a "$logFile";
        fi

    else

        if [[ "$showAllMessages" = true ]]; then
            echo -e "\t${CE}Warning! Cannot chmod 777 ${AC}${folderAbsoluteLocation}${CE} because this folder does not exist${NC}.\n" | tee -a "$logFile";
        fi

    fi

    return 0;
}

####################################################################################################################################################

saveExistingWebsiteConfiguration() {
	# app/config/parameters.yml
	if [ ! -z "${folderParametersLocation+x}" ]; then

		if [[ "$showAllMessages" = true ]]; then
			echo -e "\tINFO: File ${AC}parameters.yml${NC} was found.\n" | tee -a "$logFile";
		fi

		# parent folder for parameters.yml (folder/app/config/)
		baseParametersParentLocation=$(dirname "$baseParametersLocation");

		# create base parameters parent folder location
		mkdir -p "$baseParametersParentLocation";

		if [[ "$showAllMessages" = true ]]; then
			echo -en "\n\tINFO: Attempted to create ${AC}${baseParametersParentLocation}${NC} folder... " | tee -a "$logFile";
		fi

		# check created base parameters parent folder location
		if [[ -d "$baseParametersParentLocation" ]]; then

			if [[ "$showAllMessages" = true ]]; then
				echo -e "Success.\n" | tee -a "$logFile";
			fi

		else
			echo -e "\n\t${CE}ERROR! Failed to create ${AC}${baseParametersParentLocation}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
			exit;
		fi

		# copy parameters.yml to new location
		cp "$folderParametersLocation" "$baseParametersLocation";

		if [[ "$showAllMessages" = true ]]; then
			echo -en "\tINFO: Copying file ${AC}${folderParametersLocation}${NC} to ${AC}${baseParametersLocation}${NC}... " | tee -a "$logFile";
		fi

		# check copied parameters.yml in the new location
		if [ ! -z "${baseParametersLocation+x}" ]; then

			if [[ "$showAllMessages" = true ]]; then
				echo -e "Success.\n" | tee -a "$logFile";
			fi

		else
			echo -e "\n\t${CE}ERROR! Failed to copy ${AC}${folderParametersLocation}${CE} file. Exiting... ${NC}\n" | tee -a "$logFile";
			exit;
		fi
	else
		if [[ "$showAllMessages" = true ]]; then
			echo -e "\tINFO: File ${AC}parameters.yml${NC} was not found.\n" | tee -a "$logFile";
		fi
	fi

	return 0;
}

saveExistingWebsiteUploadDirectory() {
    # web/upload
	if [[ -d "$folderUploadLocation" ]]; then

		if [[ "$showAllMessages" = true ]]; then
			echo -e "\tINFO: ${AC}upload${NC} folder was found.\n" | tee -a "$logFile";
		fi

		# check if base/web folder exist
		if [[ ! -d "$baseWebLocation" ]]; then

			# create base/web folder
			mkdir -p "$baseWebLocation";

			if [[ "$showAllMessages" = true ]]; then
				echo -en "\tINFO: Attempted to create ${AC}${baseWebLocation}${NC} folder... " | tee -a "$logFile";
			fi

			# check created base parameters parent folder location
			if [[ -d "$baseWebLocation" ]]; then

				if [[ "$showAllMessages" = true ]]; then
					echo -e "Success.\n" | tee -a "$logFile";
				fi

			else
				echo -e "\n\t${CE}ERROR! Failed to create ${AC}${baseWebLocation}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
				exit;
			fi
		fi

		# copy upload folder to new location
		# cp "${folderUploadLocation}" "${baseWebLocation}" -r; -- DEPRECATED, because images => git
		rsync -av --progress "$folderUploadLocation" "$baseWebLocation" --exclude images;

		if [[ "$showAllMessages" = true ]]; then
			echo -en "\tINFO: Copying folder ${AC}${folderUploadLocation}${NC} to ${AC}${baseWebLocation}${NC}... " | tee -a "$logFile";
		fi

		# check copied upload folder in the new location
		if [[ -d "$baseUploadLocation" ]]; then

			if [[ "$showAllMessages" = true ]]; then
				echo -e "Success.\n" | tee -a "$logFile";
			fi

		else
			echo -e "\n\t${CE}ERROR! Failed to copy ${AC}${baseUploadLocation}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
			exit;
		fi
	else
		echo -e "\n\t${CE}Warning! ${AC}upload${CE} folder was not found.${NC}\n" | tee -a "$logFile";
	fi

	return 0;
}

saveExistingWebsiteUploadsDirectory() {
	# web/uploads
	if [[ -d "$folderUploadsLocation" ]]; then

		if [[ "$showAllMessages" = true ]]; then
			echo -e "\tINFO: ${AC}uploads${NC} folder was found.\n" | tee -a "$logFile";
		fi

		# check if base/web folder exist
		if [[ ! -d "$baseWebLocation" ]]; then

			# create base/web folder
			mkdir -p "$baseWebLocation";

			if [[ "$showAllMessages" = true ]]; then
				echo -en "\tINFO: Attempted to create ${AC}${baseWebLocation}${NC} folder... " | tee -a "$logFile";
			fi

			# check created base parameters parent folder location
			if [[ -d "$baseWebLocation" ]]; then

				if [[ "$showAllMessages" = true ]]; then
					echo -e "Success.\n" | tee -a "$logFile";
				fi

			else
				echo -e "\n\t${CE}ERROR! Failed to create ${AC}${baseWebLocation}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
				exit;
			fi
		fi

		cp "$folderUploadsLocation" "$baseWebLocation" -r;

		if [[ "$showAllMessages" = true ]]; then
			echo -en "\tINFO: Copying folder ${AC}${folderUploadsLocation}${NC} to ${AC}${baseWebLocation}${NC}... " | tee -a "$logFile";
		fi

		# check copied upload folder in the new location
		if [[ -d "$baseUploadsLocation" ]]; then

			if [[ "$showAllMessages" = true ]]; then
				echo -e "Success.\n" | tee -a "$logFile";
			fi

		else
			echo -e "\n\t${CE}ERROR! Failed to copy ${AC}${baseUploadsLocation}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
			exit;
		fi
	else
		echo -e "\n\t${CE}Warning! ${AC}uploads${CE} folder was not found.${NC}\n" | tee -a "$logFile";
	fi

	return 0;
}

saveExistingWebsiteContent() {
    # save existing website mode
    if [[ "$saveOld" = true ]]; then

        if [[ "$showAllMessages" = true ]]; then
            echo -e "\tINFO: ${AC}${folder}${NC} folder was found.\n" | tee -a "$logFile";
        fi

        saveExistingWebsiteConfiguration;
        saveExistingWebsiteUploadDirectory;
        saveExistingWebsiteUploadsDirectory;
    fi

    return 0;
}

####################################################################################################################################################

renameExistingWebsiteDirectory() {
    if [[ -d "${folderAbsoluteLocation}.old" ]]; then
        echo -e "\t${CE}Warning! ${AC}${folderAbsoluteLocation}.old${CE} folder was found. It will be removed.${NC}\n" | tee -a "$logFile";
        rm -rf "${folderAbsoluteLocation}.old";
    fi

	# rename old website folder
	mv "${websiteParentLocation}${folder}" "${websiteParentLocation}${folder}.old";

	if [[ "$showAllMessages" = true ]]; then
		echo -en "\tINFO: Attempted to rename ${AC}${folder}${NC} to ${AC}${folder}.old${NC} folder... " | tee -a "$logFile";
	fi

	# check renamed website folder
	if [[ ! -d "$folder" ]] && [[ -d "${folder}.old" ]]; then

		if [[ "$showAllMessages" = true ]]; then
			echo -e "Success.\n" | tee -a "$logFile";
		fi

	else
		echo -e "\n\t${CE}ERROR! Failed to move ${AC}${folder}${CE} to ${AC}${folder}.old${CE}. Exiting... ${NC}\n" | tee -a "$logFile";
		exit;
	fi

	return 0;
}

removeExistingWebsiteDirectory() {
    if [[ -d "$folder" ]]; then

		# remove old website folder
		rm -rf "$folder";

		if [[ "$showAllMessages" = true ]]; then
			echo -en "\tINFO: Attempted to remove ${AC}${folder}${NC} folder... " | tee -a "$logFile";
		fi

		# check removed website folder
		if [[ ! -d "$folder" ]]; then

			if [[ "$showAllMessages" = true ]]; then
				echo -e "Success.\n" | tee -a "$logFile";
			fi

		else
			echo -e "\n\t${CE}ERROR! Failed to remove ${AC}${folder}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
			exit;
		fi
	fi

	return 0;
}

processExistingWebsiteDirectory() {
    # save old / rename
    if [[ "$saveOld" = true ]]; then
        renameExistingWebsiteDirectory;
    fi

    # ignore old / remove
    if [[ "$ignoreOld" = true ]]; then
        removeExistingWebsiteDirectory;
    fi

    return 0;
}

####################################################################################################################################################

createNewWebsiteDirectory() {
	# create folder directory
	mkdir "$folder";

	if [[ "$showAllMessages" = true ]]; then
		echo -en "\tINFO: Attempted to create ${AC}${folder}${NC} folder... " | tee -a "$logFile";
	fi

	# check folder directory
	if [[ -d "$folder" ]]; then

		if [[ "$showAllMessages" = true ]]; then
			echo -e "Success.\n" | tee -a "$logFile";
		fi

	else
		echo -e "\n\t${CE}ERROR! Failed to create ${AC}${folder}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
		exit;
	fi

	return 0;
}

downloadNewWebsiteFromGit() {
	# get data from repository
	git clone "$link" "$folder" -b "$branch";

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\n\tINFO: Performed ${AC}git clone ${link} ${folder} -b ${branch}${NC} command.\n" | tee -a "$logFile";
	fi

	return 0;
}

restoreSavedConfiguration() {
	# restore parameters.yml
	if [ ! -z "${baseParametersLocation+x}" ] && [[ "$ignoreOld" = false ]]; then

		# copy parametery.yml to new location
		cp "$baseParametersLocation" "$folderParametersLocation";

		if [[ "$showAllMessages" = true ]]; then
			echo -en "\tINFO: Copying file ${AC}${baseParametersLocation}${NC} to ${AC}${folderParametersLocation}${NC}... " | tee -a "$logFile";
		fi

		# check copied parameters.yml in the new location
		if [ ! -z "${folderParametersLocation+x}" ]; then

			if [[ "$showAllMessages" = true ]]; then
				echo -e "Success.\n" | tee -a "$logFile";
			fi

		else
			echo -e "\n\t${CE}ERROR! Failed to copy ${AC}${baseParametersLocation}${CE} file. Exiting... ${NC}\n" | tee -a "$logFile";
			exit;
		fi
	fi

	return 0;
}

fillNewWebsiteDirectory() {
    if [[ "$saveOld" = true ]] || [[ "$ignoreOld" = true ]]; then
        createNewWebsiteDirectory;
        downloadNewWebsiteFromGit;
        restoreSavedConfiguration;
    fi

    return 0;
}

####################################################################################################################################################

changeActiveDirectoryToWebsite() {
    # change active folder
    cd "$folder";

    if [[ "$showAllMessages" = true ]]; then
        echo -e "\n\tINFO: Changed ${AC}active folder${NC} to ${AC}${folder}${NC}.\n" | tee -a "$logFile";
    fi

    return 0;
}

updateNewWebsiteFromGit() {
    # ignore file permissions change
    git config core.fileMode false;

	# make sure we are on the right branch
	git checkout "$branch";

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\n\tINFO: Changed ${AC}active git branch${NC} to  ${AC}${branch}${NC}.\n" | tee -a "$logFile";
	fi

	# resets your changes back to the last commit
	git reset HEAD --hard;

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\n\tINFO: ${AC}Git repository was resetted${NC} to the latest HEAD commit.\n" | tee -a "$logFile";
	fi

	# discard any new files or directories that you may have added
	git clean -f;

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\n\tINFO: ${AC}Cleaned git repository${NC} from locally added files and folders.\n" | tee -a "$logFile";
	fi

	# update branch with the latest changes
	git pull origin "$branch";

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\n\tINFO: Performed ${AC}git pull${NC} for ${AC}${branch}${NC} branch.\n" | tee -a "$logFile";
	fi

    return 0;
}

updateComposerBundles() {
	# update composer bundles
	rm -rf vendor/*/;

	# export symfony prod
	export SYMFONY_ENV=prod;

	composer update --no-interaction --quiet;

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\tINFO: Performed ${AC}composer update${NC} command.\n" | tee -a "$logFile";
	fi

	return 0;
}

clearSymfonyCache() {
	# force cache folders remove
	rm -rf app/cache/*/;

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\tINFO: Forcefully removed ${AC}cache folders${NC}." | tee -a "$logFile";
	fi

	# cache clear
	php app/console cache:clear;

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\tINFO: ${AC}Cache${NC} cleared up.\n" | tee -a "$logFile";
	fi

	return 0;
}

updateNpmPackages() {
    nodeJsDirectory='app/Resources/NodeJS';

    rm -rf "$nodeJsDirectory/node_modules";

    if [[ "$showAllMessages" = true ]]; then
		echo -e "\tINFO: Forcefully removed ${AC}previous npm packages${NC}." | tee -a "$logFile";
	fi

	# move to NodeJS directory
	cd "$nodeJsDirectory";

	# install npm packages
	npm install;

    if [[ "$showAllMessages" = true ]]; then
		echo -e "\tINFO: Attemplted to install ${AC}required npm packages${NC}." | tee -a "$logFile";
	fi

	# return to working directory: ./ -> Resources -> app -> website directory
	cd ../../../;

	return 0;
}

updateWebAssets() {
	# update web assets
	php app/console assetic:dump --no-debug;

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\n\tINFO: ${AC}Web Assets${NC} were updated.\n" | tee -a "$logFile";
	fi

    # update composer bundles assets
    php app/console assets:install web/assets --symlink;

    if [[ "$showAllMessages" = true ]]; then
		echo -e "\n\tINFO: ${AC}Composer Bundles Web Assets${NC} were updated.\n" | tee -a "$logFile";
	fi

	return 0;
}

###################################################################

installComposerBundles() {
	# export symfony prod
	export SYMFONY_ENV=prod;

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\tINFO: Set ${AC}SYMFONY_ENV${NC} to ${AC}prod${NC}.\n" | tee -a "$logFile";
	fi

	# install composer bundles
	composer install --no-interaction --quiet;

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\n\tINFO: Performed ${AC}composer install${NC} command.\n" | tee -a "$logFile";
	fi

    return 0;
}

warmUpSymfonyCache() {
    # cache warmup
	php app/console cache:warmup;

	if [[ "$showAllMessages" = true ]]; then
		echo -e "\tINFO: ${AC}Cache warmed up.${NC}\n" | tee -a "$logFile";
	fi

	return 0;
}

###################################################################

changeActiveDirectoryToWww() {
	# return to var/www/
	cd /var/www;
	if [[ "$showAllMessages" = true ]]; then
		echo -e "\tINFO: Changed active folder to ${AC}/var/www/${NC}.\n" | tee -a "$logFile";
	fi

	return 0;
}

restoreSavedUploadDirectory() {
	# copy upload
	if [[ -d "$baseUploadLocation" ]] && [[ "$ignoreOld" = false ]]; then

		# base -> folder
		cp "$baseUploadLocation" "$folderWebLocation" -r;

		if [[ "$showAllMessages" = true ]]; then
			echo -en "\tINFO: Copying folder ${AC}${baseUploadLocation}${NC} to ${AC}${folderWebLocation}${NC}... " | tee -a "$logFile";
		fi

		# check copied upload folder in the new location
		if [[ -d "$folderUploadLocation" ]]; then

			if [[ "$showAllMessages" = true ]]; then
				echo -e "Success.\n" | tee -a "$logFile";
			fi

		else
			echo -e "\n\t${CE}ERROR! Failed to restore ${AC}${baseUploadLocation}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
			exit;
		fi
	fi

	return 0;
}

restoreSavedUploadsDirectory() {
	# copy uploads
	if [[ -d "$baseUploadsLocation" ]] && [[ "$ignoreOld" = false ]]; then

		cp "$baseUploadsLocation" "$folderWebLocation" -r;

		if [[ "$showAllMessages" = true ]]; then
			echo -en "\tINFO: Copying folder ${AC}${baseUploadsLocation}${NC} to ${AC}${folderWebLocation}${NC}... " | tee -a "$logFile";
		fi

		# check copied upload folder in the new location
		if [[ -d "$folderUploadsLocation" ]]; then

			if [[ "$showAllMessages" = true ]]; then
				echo -e "Success.\n" | tee -a "$logFile";
			fi

		else
			echo -e "\n\t${CE}ERROR! Failed to restore ${AC}${baseUploadsLocation}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
			exit;
		fi
	fi

	return 0;
}

removeTemporaryDirectory() {
    # remove base site branch folder
	rm "$baseSiteBranchFolder" -rf;

	if [[ "$showAllMessages" = true ]]; then
		echo -en "\tINFO: Attempted to remove ${AC}${baseSiteBranchFolder}${NC} folder... " | tee -a "$logFile";
	fi

	# check removed folder
	if [[ ! -d "$baseSiteBranchFolder" ]]; then

		if [[ "$showAllMessages" = true ]]; then
			echo -e "Success.\n" | tee -a "$logFile";
		fi

	else
		echo -e "\n\t${CE}ERROR! Failed to remove ${AC}${baseSiteBranchFolder}${CE} folder. Exiting... ${NC}\n" | tee -a "$logFile";
		exit;
	fi

	return 0;
}

createDownloadsSymbolicLink() {
	# create symbolic link to downloads folder
    ln -s "$downloadsSourceAbsoluteLocation" "$folderDownloadsAbsoluteLocation";

    if [[ "$showAllMessages" = true ]]; then
		echo -e "\tINFO: ${AC}Symlink${NC} to downloads folder was created.\n" | tee -a "$logFile";
	fi

	return 0;
}

checkDownloadsSymbolicLink() {
    if [ ! -L "$folderDownloadsAbsoluteLocation" ]; then
        createDownloadsSymbolicLink;
    fi

    return 0;
}

initializeSymfonyApplication() {

    if [[ "$updateOld" = true ]]; then
        updateNewWebsiteFromGit;
        updateComposerBundles;
        clearSymfonyCache;
        updateNpmPackages;
        updateWebAssets;
        checkDownloadsSymbolicLink;
    fi

    if [[ "$saveOld" = true ]] || [[ "$ignoreOld" = true ]]; then
        installComposerBundles;
        warmUpSymfonyCache;
        updateNpmPackages;
        updateWebAssets;

        changeActiveDirectoryToWww;
        restoreSavedUploadDirectory;
        restoreSavedUploadsDirectory;
        removeTemporaryDirectory;
        createDownloadsSymbolicLink;
    fi

    return 0;
}

printFinalMessage() {
    echo -e "\n\t${AC}Deployment is finished${NC}. Please do not forget to check web/upload and web/uploads content.\n" | tee -a "$logFile";
    return 0;
}

####################################################################################################################################################
####################################################################################################################################################
####################################################################################################################################################

#
# Core Configuration Area
#
# This area is needed to set colors for strings and log file name.
#

setSystemVariables;

####################################################################################################################################################

#
# Configuration Area
#
# An area where core variables are set. These variables are needed for future work.
#

setDefaultFlags;
setWebsiteVariables;
setDescription;
setArguments;

####################################################################################################################################################

#
# Arguments Handling Area
#
# Code below is needed to handle argument values, validate them and save.
#

handleArguments "$@";

####################################################################################################################################################

#
# Required Parameters Check Area
#
# This area is needed to check required parameters. In this case - website name and branch name.
#

checkRequiredParameters;

####################################################################################################################################################

#
# Extended Argument Handling Area
#
# This area sets variables derived from user defined ones.
#

setCombinedParameters;

####################################################################################################################################################

#
# Preparations For Actual Work Area
#
# Code below checks if base site branch folder (if it exists, that means previous script run was failed) and real site folder for existing.
#

makeTemporaryDirectory;

####################################################################################################################################################

#
# Existing Website Folder Processing Area
#
# This area is needed to remove or rename existing website folder.
#

checkExistingWebsiteDirectory;
chmodExistingWebsiteDirectory;
saveExistingWebsiteContent;

####################################################################################################################################################

#
# Existing Website Cleaning Area
#
# This is the place where existing website folder are being removed, renamed or updated accordingly to user's choice.
#

processExistingWebsiteDirectory;

####################################################################################################################################################

#
# Restore Existing Website Resource Data
#
# This is the place where all previously saved resources are being restored for the new deployment.
#

fillNewWebsiteDirectory;

####################################################################################################################################################

#
# Symfony Initialization Area
#
# Install composer bundles, update assetic, warmup cache, sudo chmod website directory.
#

changeActiveDirectoryToWebsite;
initializeSymfonyApplication;
chmodExistingWebsiteDirectory;

####################################################################################################################################################

printFinalMessage;
