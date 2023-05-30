#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package       : ExcelDataReader
# Version       : 3.7.0-develop00365
# Source repo   : https://github.com/ExcelDataReader/ExcelDataReader.git
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

PACKAGE_NAME=ExcelDataReader
PACKAGE_VERSION=${1:-3.7.0-develop00365}
PACKAGE_URL=https://github.com/ExcelDataReader/ExcelDataReader.git

DOTNET_VERSION=7.0

yum -y update && yum install -y  "dotnet-sdk-$DOTNET_VERSION" git

SDK_VERSION=$(dotnet --version)
echo ".NET SDK Version is " $SDK_VERSION

git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout v"$PACKAGE_VERSION"

for file in `find . -type f -name "*.csproj"`;
do
	# update target framework
        sed -i '/^[[:blank:]]*<TargetFrameworks>/c\<TargetFrameworks>net'"$DOTNET_VERSION"'</TargetFrameworks>' $file  ;
	# update Microsoft.NET.Test.Sdk  version to higher than 17.5.0 
	sed -i '/^[[:blank:]]*<PackageReference Include=\"Microsoft.NET.Test.Sdk\"/c\<PackageReference Include=\"Microsoft.NET.Test.Sdk\" Version=\"17.6.0\" />' $file  
	# use package from nuget as we are not going to build it locally
	sed -i '/ExcelDataReader.csproj/c\<PackageReference Include=\"ExcelDataReader\" Version=\"'"$PACKAGE_VERSION"'\" />' $file ;
done

# go to test directory
cd test/ExcelDataReader.Tests

# Fix test cases failures due to path/name issues
sed -i 's/Test_Git_Issue_51.xls/Test_git_issue_51.xls/g' ExcelBinaryReaderTest.cs
sed -i 's/Test_Git_Issue_145.xls/Test_git_issue_145.xls/g' ExcelBinaryReaderTest.cs
sed -i 's+\\\\+/+g' ExcelCsvReaderTest.cs
sed -i 's/fillreport.xlsx/Fillreport.xlsx/g' ExcelOpenXmlReaderTest.cs
sed -i 's+\\\\+/+g' ExcelOpenXmlStrictReaderTest.cs


if ! dotnet test; then
        echo "Test fails"
        exit 2
else
        echo "Test successful"
        exit 0
fi

