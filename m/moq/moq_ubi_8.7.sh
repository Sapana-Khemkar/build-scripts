#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package       : moq4
# Version       : 4.18.4
# Source repo   : https://github.com/moq/moq4.git
# Tested on     : UBI 8.7
# Language      : C#
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Sapana Khemkar <Sapana.Khemkar@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=moq4
PACKAGE_VERSION=${1:-4.18.4}
PACKAGE_URL=https://github.com/moq/moq4.git

DOTNET_VERSION=7.0

#yum -y update && yum install -y  "dotnet-sdk-$DOTNET_VERSION" git

SDK_VERSION=$(dotnet --version)
echo ".NET SDK Version is " $SDK_VERSION

git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout "v$PACKAGE_VERSION"

for file in `find . -type f \( -name "*.csproj" -o -name "*.fsproj" -o -name "*.vbproj" -o -name "*.props" \)`; 
do 
        # update target framework 
        sed -i '/^[[:blank:]]*<TargetFramework>/c\<TargetFramework>net7.0</TargetFramework>' $file  ;
	sed -i '/^[[:blank:]]*<TargetFrameworks>/c\<TargetFrameworks>net7.0</TargetFrameworks>' $file  ;
        # update Microsoft.NET.Test.Sdk  version to higher than 17.5.0 
        sed -i '/^[[:blank:]]*<PackageReference Include=\"Microsoft.NET.Test.Sdk\"/c\<PackageReference Include=\"Microsoft.NET.Test.Sdk\" Version=\"17.6.0\" />' $file; 
done


cd tests/Moq.Tests

# workaround to fix build issue. Need proper fix here
git apply /build-scripts/m/moq/moq_workaround.patch

if ! dotnet test; then
        echo "Test fails"
        exit 2
else
        echo "Test successful"
        exit 0
fi


