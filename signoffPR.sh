#!/usr/bin/env bash

# signoffPullRequest, a script to merge a Github Pull Request into the
# current HEAD, as well as applying a signoff.
# Copyright © 2016 Jamie Tanna
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -eou pipefail

function usage() {
	cat <<EOF
signoffPR.sh PR_ID
i.e. https://github.com/jamietanna/signoffPR/pull/1 would have PR_ID=1
EOF
}

function download_url() {
	if command -v curl >/dev/null 2>&1; then
		curl "$1" -o "$2"
	elif command -v wget >/dev/null 2>&1; then
		wget "$1" -O "$2"
	else
		echo "ERROR: install curl or wget"
		exit 1
	fi
}

function repo_url () {
	local remote
	remote="${1:-origin}"
	remote_path="$(git remote -v | grep --color=auto "$remote" | cut -f2 | cut -f1 -d' ' | tail -n1)"

	https_path="${remote_path//:/\/}"
	https_path="${https_path//git@/https:\/\/}"
	echo "${https_path}"
}

patch_id="${1:-}"
if [[ -z "$patch_id" ]];
then
	echo -e "\033[91mError: no patch ID given\033[0m"
	usage
	exit 1
fi

patch_file="${patch_id}.patch"
patch_url="$(repo_url origin)/pull/$patch_file"
download_url "$patch_url" "$patch_file"

git am -s < "$patch_file"
