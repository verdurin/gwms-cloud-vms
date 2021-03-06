#!/bin/bash

export BUILD_HOME=`pwd`

function setup_rpmbuild
{
    # setup the rpmbuild area
    mkdir -p $BUILD_HOME/rpmbuild/BUILD \
             $BUILD_HOME/rpmbuild/RPMS \
             $BUILD_HOME/rpmbuild/RPMS \
             $BUILD_HOME/rpmbuild/SOURCES \
             $BUILD_HOME/rpmbuild/SPECS \
             $BUILD_HOME/rpmbuild/SRPMS

    export RPM_TOPDIR=$BUILD_HOME/rpmbuild
}

function setup_rmpmmacros
{
    # setup rmpmmacros
    export RPMMACROS_EXISTS=0
    if [ -f ~/.rpmmacros ]
    then
        export RPMMACROS_EXISTS=1
        mv ~/.rpmmacros ~/rpmmacros_save
    fi
    cp rpmmacros ~/.rpmmacros
}

function build_source_tarball
{
    # Build the source tar for rpm_build
    tar --create --gzip --verbose --files-from=source_list.txt --file=$BUILD_HOME/glideinwms_pilot.tar.gz
    mv $BUILD_HOME/glideinwms_pilot.tar.gz $RPM_TOPDIR/SOURCES
}

function setup_spec_files
{
    cp $BUILD_HOME/rpm_specs/glideinwms-vm.spec $RPM_TOPDIR/SPECS/
}

function build_rpms
{
    # build the rpm
    rpmbuild -ba $RPM_TOPDIR/SPECS/glideinwms-vm.spec
    mkdir -p $BUILD_HOME/rpms
    cp -r $RPM_TOPDIR/RPMS/* $BUILD_HOME/rpms
}

function cleanup
{
    # Remove custom .rpmmacros and restore original .rpmmacros if necessary
    rm -rf ~/.rpmmacros
    if [[ $RPMMACROS_EXISTS -eq 1 ]]; then
        mv ~/rpmmacros_save ~/.rpmmacros
    fi

    # remove the rpmbuild directory
    rm -rf $RPM_TOPDIR
}

function main
{
    # setup rpmbuild environment
    echo "setup rpmbuild environment"
    setup_rpmbuild
    setup_rmpmmacros

    # prepare the source and put it in the proper location
    echo "prepare the source and put it in the proper location"
    build_source_tarball
    setup_spec_files

    # actually build the rpm 
    echo "build rpms"
    build_rpms

    # cleanup after ourselves
    echo "clean up"
    cleanup
}

main


