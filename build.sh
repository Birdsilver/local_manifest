#!/bin/bash
# Generic Variables
_android="6.0.1"
_android_version="MarshMallow"
_custom_android="cm-13.0"
_custom_android_version="LineageOS13.0"
_github_custom_android_place="LineageOS"
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

	_java_install() {
		echo "  |"
		echo "  | Let's install dependencies!"
		echo "  | Adding OpenJDK Repository!"
		sudo apt-add-repository ppa:openjdk-r/ppa -y
		sudo apt-get update
	}

	_if_check_java_fail() {
		_java=$(java -version 2>&1 | head -1 | grep -o 1.8)
		if [ "${_java}" == "1.8" ]
		then
			_javac=$(javac -version 2>&1 | head -1 | grep -o 1.8)
			if [ ! "${_javac}" == "1.8" ]
			then
				echo "  |"
				echo "  | OpenJDK 8 not is default Java!"
				echo "  | Default Java is (${_javac})!"
				${1}
			fi
		else
			echo "  |"
			echo "  | OpenJDK 8 not is default Java!"
			echo "  | Default Java is (${_java})!"
			${1}
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
			echo "  | -l1ii | --v1    | To build only for L1II/v1"
			echo "  | -l3ii | --vee3  | To build only for L3II/vee3"
			echo "  |"
			echo "  | -a    | --all   | To build for all devices"
			_option_exit="enable"
			_unset_and_stop
		fi
		# Choose device before menu
		if [[ "${_u2t}" == "-l5" || "${_u2t}" == "--e610" ]]
		then
			_device_build="e610" _device_echo="L5"
		fi
		if [[ "${_u2t}" == "-l7" || "${_u2t}" == "--p700" ]]
		then
			_device_build="p700" _device_echo="L7"
		fi
		if [[ "${_u2t}" == "-l1ii" || "${_u2t}" == "--v1" ]]
		then
			_device_build="v1" _device_echo="L1II"
		fi
		if [[ "${_u2t}" == "-l3ii" || "${_u2t}" == "--vee3" ]]
		then
			_device_build="vee3" _device_echo="L3II"
		fi
		if [[ "${_u2t}" == "-a" || "${_u2t}" == "--all" ]]
		then
			_device_build="all" _device_echo="All Devices"
		fi
	done

	# Exit if option is 'help'
	if [ "${_option_exit}" == "enable" ]
	then
		unset _option_exit
		_unset_and_stop
	fi

	# Install dependencies for building Android
	# Pulled from:
	# <http://developer.sonymobile.com/open-devices/aosp-build-instructions/how-to-build-aosp-nougat-for-unlocked-xperia-devices/>
	# <https://source.android.com/source/initializing.html>
	# <https://github.com/akhilnarang/scripts>
	_if_check_java_fail _java_install

	echo "  |"
	echo "  | Downloading dependencies!"
	sudo apt-get -y install git-core python gnupg flex bison gperf libsdl1.2-dev libesd0-dev libwxgtk2.8-dev \
squashfs-tools build-essential zip curl libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk pngcrush \
schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev \
gcc-multilib liblz4-* pngquant ncurses-dev texinfo gcc gperf patch libtool \
automake g++ gawk subversion expat libexpat1-dev python-all-dev binutils-static bc libcloog-isl-dev \
libcap-dev autoconf libgmp-dev build-essential gcc-multilib g++-multilib pkg-config libmpc-dev libmpfr-dev lzma* \
liblzma* w3m android-tools-adb maven ncftp figlet
	sudo apt-get -f -y install

	# Check Java
	_if_check_java_fail _unset_and_stop

	# Repo Sync
	echo "  |"
	echo "  | Starting Sync of Android Tree Manifest"

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
	echo "  | Downloading local manifest"
	echo "  | From ${_github_device_place} (${_custom_android})"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/local_manifest.xml -O -L https://raw.github.com/${_github_device_place}/local_manifest/${_custom_android}/local_manifest.xml"

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

	# Force usage of (FULL WORKING) Java8
	export EXPERIMENTAL_USE_JAVA8=true

	# Initialize environment
	echo "  |"
	echo "  | Initializing the environment"
	_if_fail_break "source build/envsetup.sh"

	# Another device choice
	echo "  |"
	echo "  | For what device you want to build:"
	echo "  |"
	echo "  | 1 | LG Optimus L5 NoNFC | E610 E612 E617"
	echo "  | 2 | LG Optimus L7 NoNFC | P700 P705"
	echo "  | 3 | LG Optimus L1II Single Dual | E410 E411 E415 E420"
	echo "  | 4 | LG Optimus L3II Single Dual | E425 E430 E431 E435"
	echo "  |"
	echo "  | 5 | All devices"
	echo "  |"
	if [ "${_device_build}" == "" ]
	then
		read -p "  | Choice | 1/2/3/4/5 or * to exit | " -n 1 -s x
		case "${x}" in
			1) _device_build="e610" _device_echo="L5";;
			2) _device_build="p700" _device_echo="L7";;
			3) _device_build="v1" _device_echo="L1II";;
			4) _device_build="vee3" _device_echo="L3II";;
			5) _device_build="all" _device_echo="All Devices";;
			*) echo "${x} | Exiting from script!"; _unset_and_stop;;
		esac
	fi
	echo "${x} | Building to ${_device_echo}"

	# Builing Android
	echo "  |"
	echo "  | Starting Android Building!"
	if [[ "${_device_build}" == "e610" || "${_device_build}" == "all" ]]
	then
		_if_fail_break "brunch e610"
	fi
	if [[ "${_device_build}" == "p700" || "${_device_build}" == "all" ]]
	then
		_if_fail_break "brunch p700"
	fi
	if [[ "${_device_build}" == "v1" || "${_device_build}" == "all" ]]
	then
		_if_fail_break "brunch v1"
	fi
	if [[ "${_device_build}" == "vee3" || "${_device_build}" == "all" ]]
	then
		_if_fail_break "brunch vee3"
	fi

	# Exit
	_unset_and_stop
done

# Goodbye!
echo "  |"
echo "  | Thanks for using this script!"
