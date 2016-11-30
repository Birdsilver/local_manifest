#!/bin/bash
# Generic Variables
_android="4.4.4"
_android_version="KitKat"
_custom_android="cm-11.0"
_custom_android_version="CyanogenMod11.0"
_github_custom_android_place="CyanogenMod"
_github_device_place="TeamHackLG"
# Make loop for usage of 'break' to recursive exit
while true
do
	_unset_and_stop() {
		unset _device _device_build _device_echo
		break
	}

	_if_fail_break() {
		${1}
		if ! [ "${?}" == "0" ]
		then
			echo "  |"
			echo "  | Something failed!"
			echo "  | Exiting from script!"
			_unset_and_stop
		fi
	}

	# Unset devices variables for not have any problem
	unset _device _device_build _device_echo

	# Check if is using 'BASH'
	if [ ! "${BASH_VERSION}" ]
	then
		echo "  |"
		echo "  | Please do not use 'sh' to run this script"
		echo "  | Just use 'source build.sh'"
		echo "  | Exiting from script!"
		_unset_and_stop
	fi

	# Check if 'curl' is installed
	if [ ! "$(which curl)" ]
	then
		echo "  |"
		echo "  | You will need 'curl'"
		echo "  | Use 'sudo apt-get install curl' to install 'curl'"
		echo "  | Exiting from script!"
		_unset_and_stop
	fi

	# Check if 'repo' is installed
	if [ ! "$(which repo)" ]
	then
		# Load this value
		export PATH=~/bin:$PATH

		# Check again for repo
		if [ ! "$(which repo)" ]
		then
			echo "  |"
			echo "  | Installing 'repo'"

			# Download repo inside of bin dir
			_if_fail_break "curl -# --create-dirs -L -o ~/bin/repo -O -L http://commondatastorage.googleapis.com/git-repo-downloads/repo"

			# Make it executable
			chmod a+x ~/bin/repo

			# Let's check if repo is include
			if [ $(cat $(ls .bash* | grep -v -e history -e logout) | grep "export PATH=~/bin:\$PATH" | wc -l) == "0" ]
			then
				# Add it to bashrc
				echo "export PATH=~/bin:\$PATH" >> ~/.bashrc
			fi
		fi
	fi

	# Name of script
	echo "  |"
	echo "  | Live Android Sync and Build Script"
	echo "  | For Android ${_android_version} (${_android}) | ${_custom_android_version} (${_custom_android})"

	# Check option of user and transform to script
	for _u2t in "${@}"
	do
		if [[ "${_u2t}" == "-h" || "${_u2t}" == "--help" ]]
		then
			echo "  |"
			echo "  | Usage:"
			echo "  | -h    | --help  | To show this message"
			echo "  |"
			echo "  | -l5   | --e610  | To build only for L5/e610"
			echo "  | -l7   | --p700  | To build only for L7/p700"
			echo "  | -gen1 | --gen1  | To build for L5 and L7"
			echo "  |"
			echo "  | -l1ii | --v1    | To build only for L1II/v1"
			echo "  | -l3ii | --vee3  | To build only for L3II/vee3"
			echo "  | -gen2 | --gen2  | To build for L1II and L3II"
			_option_exit="enable"
			_unset_and_stop
		fi
		# Choose device before menu
		if [[ "${_u2t}" == "-l5" || "${_u2t}" == "--e610" ]]
		then
			_device="gen1"
			_device_build="e610"
			_device_echo="L5"
		fi
		if [[ "${_u2t}" == "-l7" || "${_u2t}" == "--p700" ]]
		then
			_device="gen1"
			_device_build="p700"
			_device_echo="L7"
		fi
		if [[ "${_u2t}" == "-gen1" || "${_u2t}" == "--gen1" ]]
		then
			_device="gen1"
			_device_build="gen1"
			_device_echo="All Gen1"
		fi
		if [[ "${_u2t}" == "-l1ii" || "${_u2t}" == "--v1" ]]
		then
			_device="gen2"
			_device_build="v1"
			_device_echo="L1II"
		fi
		if [[ "${_u2t}" == "-l3ii" || "${_u2t}" == "--vee3" ]]
		then
			_device="gen2"
			_device_build="vee3"
			_device_echo="L3II"
		fi
		if [[ "${_u2t}" == "-gen2" || "${_u2t}" == "--gen2" ]]
		then
			_device="gen2"
			_device_build="gen2"
			_device_echo="All Gen2"
		fi
	done

	# Exit if option is 'help'
	if [ "${_option_exit}" == "enable" ]
	then
		unset _option_exit
		_unset_and_stop
	fi

	# Repo Sync
	echo "  |"
	echo "  | Starting Sync of Android Tree Manifest"

	# Device Choice
	echo "  |"
	echo "  | Choose Manifest to download:"
	echo "  | 1 | First Generation Devices  | LG Optimus L5/L7 (NoNFC)"
	echo "  | 2 | Second Generation Devices | LG Optimus L3II/L1II"
	echo "  |"
	if [ "${_device}" == "" ]
	then
		read -p "  | Choice | 1/ 2/ or any key to exit | " -n 1 -s x
		case "${x}" in
			1) _device="gen1";;
			2) _device="gen2";;
			*) echo "${x} | Exiting from script!"; _unset_and_stop;;
		esac
	fi
	echo "  | Using ${_device}_manifest.xml"

	# Remove old Manifest of Android Tree
	echo "  |"
	echo "  | Removing old Manifest before download new one"
	rm -rf .repo/manifests .repo/manifests.git .repo/manifest.xml .repo/local_manifests/

	# Initialization of Android Tree
	echo "  |"
	echo "  | Downloading Android Tree Manifest from ${_github_custom_android_place} (${_custom_android})"
	_if_fail_break "repo init -u https://github.com/${_github_custom_android_place}/android.git -b ${_custom_android} -g all,-notdefault,-darwin"

	# Device manifest download
	echo "  |"
	echo "  | Downloading ${_device}_manifest.xml and msm7x27a_manifest.xml"
	echo "  | From ${_github_device_place} (${_custom_android})"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/${_device}_manifest.xml -O -L https://raw.github.com/${_github_device_place}/local_manifest/${_custom_android}/${_device}_manifest.xml"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/msm7x27a_manifest.xml -O -L https://raw.github.com/${_github_device_place}/local_manifest/${_custom_android}/msm7x27a_manifest.xml"

	# Use optimized reposync
	echo "  |"
	echo "  | Starting Sync:"
	if [ -f "build/envsetup.sh" ]
	then
		_if_fail_break "source build/envsetup.sh"
		_if_fail_break "reposync -c --force-sync -q"
	else
		_if_fail_break "repo sync -c --force-sync -q"
	fi

	# Initialize environment
	echo "  |"
	echo "  | Initializing the environment"
	_if_fail_break "source build/envsetup.sh"

	# Another device choice
	echo "  |"
	echo "  | For what device you want to build:"
	echo "  |"
	if [ "${_device}" == "gen1" ]
	then
		echo "  | 1 | LG Optimus L5 NoNFC | E610 E612 E617"
		echo "  | 2 | LG Optimus L7 NoNFC | P700 P705"
		echo "  | 3 | All First Generation devices"
		echo "  |"
		if [ "${_device_build}" == "" ]
		then
			read -p "  | Choice | 1/2/3/ or * to exit | " -n 1 -s x
			case "${x}" in
				1) _device_build="e610" _device_echo="L5";;
				2) _device_build="p700" _device_echo="L7";;
				3) _device_build="gen1" _device_echo="All Gen1";;
				*) echo "${x} | Exiting from script!"; _unset_and_stop;;
			esac
		fi
	elif [ "${_device}" == "gen2" ]
	then
		echo "  | 1 | LG Optimus L1II Single Dual | E410 E411 E415 E420"
		echo "  | 2 | LG Optimus L3II Single Dual | E425 E430 E431 E435"
		echo "  | 3 | All Second Generation devices"
		echo "  |"
		if [ "${_device_build}" == "" ]
		then
			read -p "  | Choice | 1/2/3/ or * to exit | " -n 1 -s x
			case "${x}" in
				1) _device_build="v1" _device_echo="L1II";;
				2) _device_build="vee3" _device_echo="L3II";;
				3) _device_build="gen2" _device_echo="All Gen2";;
				*) echo "${x} | Exiting from script!"; _unset_and_stop;;
			esac
		fi
		# Patchs
		echo "  |"
		echo "  | Applying the patches"
		sh device/lge/vee3/patches/apply.sh
	fi
	echo "  | Building to ${_device_echo}"
	# Builing Android
	echo "  |"
	echo "  | Starting Android Building!"
	if [[ "${_device_build}" == "e610" || "${_device_build}" == "gen1" ]]
	then
		_if_fail_break "brunch e610"
	fi
	if [[ "${_device_build}" == "p700" || "${_device_build}" == "gen1" ]]
	then
		_if_fail_break "brunch p700"
	fi
	if [[ "${_device_build}" == "v1" || "${_device_build}" == "gen2" ]]
	then
		_if_fail_break "brunch v1"
	fi
	if [[ "${_device_build}" == "vee3" || "${_device_build}" == "gen2" ]]
	then
		_if_fail_break "brunch vee3"
	fi

	# Exit
	_unset_and_stop
done

# Goodbye!
echo "  |"
echo "  | Thanks for using this script!"
