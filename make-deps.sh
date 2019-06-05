#!/bin/bash

# determine the root directory of the package repo

REPO_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
if [ ! -d  "${REPO_DIR}/.git" ]; then
    2>&1 echo "${REPO_DIR} is not a git repository"
    exit 1
fi

# the first and the only argument should be the version of apache-tomcat

NAME=$(basename ${BASH_SOURCE[0]})
if [ $# -ne 1 ]; then
    2>&1 cat <<EOF
Usage: $NAME <apache-tomcat version>
EOF
    exit 2
fi

TOMCAT_VERSION=$1

### move previous repository temporarily
if [ -d ${HOME}/tomcat-build-libs ]; then
        mv ${HOME}/tomcat-build-libs ${HOME}/tomcat-build-libs.backup.$$
fi

### fetch the apache-tomcat sources and unpack

TOMCAT_TGZ=${TOMCAT_VERSION}.tar.gz

if [ ! -f "${TOMCAT_TGZ}" ]; then
    TOMCAT_URL=https://github.com/apache/tomcat/archive/${TOMCAT_TGZ}
    if ! curl -L -o "${TOMCAT_TGZ}" "${TOMCAT_URL}"; then
        2>&1 echo Failed to download sources: $TOMCAT_URL
        exit 1
    fi
fi

cd "${REPO_DIR}"

# assume all the files go to a subdir (so any file will give us the directory
# it's extracted to)
TOMCAT_DIR=$(tar xzvf "${TOMCAT_TGZ}" | head -1)
TOMCAT_DIR=${TOMCAT_DIR%%/*}
tar xzf "${TOMCAT_TGZ}"

### fetch the apache-tomcat depenencies and store the log (to retrieve the urls)

cd "${TOMCAT_DIR}"

# patch it as per the apache-tomcat.spec (assume files do not contain spaces)
PATCHES=$(grep ^Patch "${REPO_DIR}/../apache-tomcat/apache-tomcat.spec" | sed -e 's/Patch[0-9]\+\s*:\s*\(\S\)\s*/\1/')

for p in $PATCHES; do
    patch -p1 < "${REPO_DIR}/../apache-tomcat/${p}"
done

ant release | tee apache-tomcat.build.out

cd "${REPO_DIR}"

# remove previously created artifacts
rm -f sources.txt install.txt files.txt metadata-*.patch

### make the list of the dependency urls
DEPENDENCIES=($(grep '^\s*\[get\] Getting:\s*' "${TOMCAT_DIR}/apache-tomcat.build.out" | sed -e 's/^\s*\[get\] Getting:\s*//' | uniq))


### create pieces of the spec (SourceXXX definitions and their install actions)

# these are two repositories gradle is configured to use (explicitly via
# add-remote-repos.patch)
REPOSITORY_URLS=(
                https://downloads.sourceforge.net
                http://www.apache.org
                http://archive.eclipse.org
                https://repo.maven.apache.org
                )
# apache-tomcat specifically has some basename clashes which results download conflicts
# when used in .spec as-is. keep track of these files to name them differently.
declare -A FILE_MAP
SOURCES_SECTION=""
INSTALL_SECTION=""
FILES_SECTION=""
warn=
n=0

for dep in ${DEPENDENCIES[@]}; do
    dep_bn=$(basename "$dep")
    dep_sfx=""
    if [ -n "${FILE_MAP[${dep_bn}]}" ]; then
        let dep_sfx=${FILE_MAP[${dep_bn}]}+1
        FILE_MAP[${dep_bn}]=${dep_sfx}
    else
        FILE_MAP[${dep_bn}]=0
    fi
    for url in ${REPOSITORY_URLS[@]}; do
        dep_path=${dep##$url}
        # if we actually removed the url, then it's a mismatch (i.e. success)
        if [ "${dep_path}" != "${dep}" ]; then
            dep_url="${dep}"
            dep="${dep_path}"
            break
        fi
    done
    [ -z "$dep_url" ] && continue
    dep_dn=$(dirname "${dep_path}")
    dep_fn="${dep_bn}${dep_sfx}" # downloaded filename
    if [ -n "${dep_sfx}" ]; then
        dep_url="${dep_url}#/${dep_fn}"
    fi
    SOURCES_SECTION="${SOURCES_SECTION}
Source${n} : ${dep_url}"
    INSTALL_SECTION="${INSTALL_SECTION}
cp %{SOURCE${n}} %{buildroot}/usr/share/apache-tomcat/"
    FILES_SECTION="${FILES_SECTION}
/usr/share/apache-tomcat/${dep_fn}"
    let n=${n}+1
done

cd "${REPO_DIR}"

echo "${SOURCES_SECTION}" | sed -e '1d' > sources.txt
echo "${INSTALL_SECTION}" | sed -e '1d' > install.txt
echo "${FILES_SECTION}" | sed -e '1d' > files.txt

cat <<EOF
sources.txt     contains SourceXXXX definitions for the spec file.
install.txt     contains %install section.
files.txt       contains the %files section.
EOF

# restore previous repo
rm -rf ${HOME}/tomcat-build-libs
if [ -d ${HOME}/tomcat-build-libs.backup.$$ ]; then
    mv ${HOME}/tomcat-build-libs.backup.$$ ${HOME}/tomcat-build-libs 
fi
# vim: si:noai:nocin:tw=80:sw=4:ts=4:et:nu
