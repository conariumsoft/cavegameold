#!/bin/bash
echo "building love file..."

echo "cleaning old build..."
file=./bin/temp/
if [ -a "$file" ]; then
	rm -rf bin/temp/
fi
file=./bin/win64/temp/
if [ -a "$file" ]; then
	rm -rf bin/win64/temp/
fi


echo "copying game data.."
mkdir bin/temp/
cp -r assets/ bin/temp/
cp -r data/ bin/temp/
cp -r JUI/ bin/temp/
cp -r src/ bin/temp/
cp config.lua bin/temp/
cp changes.txt bin/temp/
cp main.lua bin/temp/

cd bin/temp/
echo "compressing..."
{
	zip -r ../cavegame.zip *
} &> /dev/null

cd ../../

mv bin/cavegame.zip bin/cavegame.love

mkdir bin/win64/temp/
cp bin/win64/love2d/* bin/win64/temp/
echo "building win64 executable"
cat bin/win64/temp/love.exe bin/cavegame.love > bin/win64/temp/cavegame.exe
rm bin/win64/temp/love.exe
rm bin/win64/temp/lovec.exe


cd bin/win64/temp/

echo "compressing..."
{
	zip -r ../cavegame-win64.zip *
} &> /dev/null

cd ../../../

rm -rf bin/win64/temp
rm -rf bin/temp/
echo "done!"