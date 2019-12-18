/*
 *  Copyright (C) 2019  Attila Aldemir <a_aldemir@hotmail.de>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

const fs = require('fs');
const path = require('path');


/*###################################################################################################
# CONFIGURATION
###################################################################################################*/

/*###################################################################################################
# FUNCTIONS
###################################################################################################*/

const findFiles = (dir, fileList = []) => {
    fs.readdirSync(dir).forEach(file => {
        fileList = fs.statSync(path.join(dir, file)).isDirectory()
            ? findFiles(path.join(dir, file), fileList)
            : fileList.concat(path.join(dir, file));
    });
    return fileList;
}


const prepareImageFiles = (imageFiles, outputFolder) => {
    imageFiles.forEach((file) => {
        const outputPathName = path.join(outputFolder, path.basename(file));
        fs.copyFileSync(file, outputPathName);
    });
}


const prepareMarkdownFiles = (markdownFiles, outputFolder) => {
    markdownFiles.forEach((file) => {
        let fileContent = fs.readFileSync(file, 'utf8').split(/\r\n|\n/);

        fileContent = convertTocLinks(fileContent);
        fileContent = convertImageLinks(fileContent);
        fileContent = convertMarkdownLinks(fileContent);

        const outputPathName = path.join(outputFolder, path.basename(file));
        fs.writeFileSync(outputPathName, fileContent.join('\n'));
    });
}

const convertTocLinks = (fileContent) => {
    let newContent = [];
    fileContent.forEach((line) => {
        
        if(line.includes("- [") && line.includes("](#") && line.includes(")")) {
            const start = line.lastIndexOf("](#") + 3;
            const end = line.lastIndexOf(")");
            
            const headerLink = line.substring(start, end);
            const newHeaderLink = headerLink.toLowerCase();
            
            const newReference = line.substring(0, start) + newHeaderLink + ")";
            newContent.push(newReference)
        } else {
            newContent.push(line)
        }
    });

    return newContent;
}

const convertImageLinks = (fileContent) => {
    let newContent = [];
    fileContent.forEach((line) => {
        
        if(line.includes("![](") && line.includes(")") && !line.includes("http://") && !line.includes("https://")) {
            const start = line.lastIndexOf("![](") + 4;
            const end = line.lastIndexOf(")");
            
            const imagePath = line.substring(start, end);
            const newImagePath = path.parse(imagePath).base;
            
            const newImageLink = line.substring(0, start) + newImagePath + ")";
            newContent.push(newImageLink)
        } else {
            newContent.push(line)
        }
    });

    return newContent;
}

const convertMarkdownLinks = (fileContent) => {
    let newContent = [];
    fileContent.forEach((line) => {
        
        if(line.includes("[") && line.includes("](") && line.includes(")") && !line.includes("http://") && !line.includes("https://")) {
            const start = line.lastIndexOf("](") + 2;
            const end = line.lastIndexOf(")");
            
            const filePath = line.substring(start, end);
            const newFilePath = path.parse(filePath).base;
            
            const newFileLink = line.substring(0, start) + newFilePath + ")";
            newContent.push(newFileLink)
        } else {
            newContent.push(line)
        }
    });

    return newContent;
} 


/*###################################################################################################
# MAIN
###################################################################################################*/

const inputFolder = path.normalize(process.argv[2]);
const outputFolder = path.normalize(process.argv[3]);

if (!fs.existsSync(outputFolder)) fs.mkdirSync(outputFolder);


const files = findFiles(inputFolder);
const imageFiles = files.filter((file) => file.endsWith('.png') || file.endsWith('.svg'));
const markdownFiles = files.filter((file) => file.endsWith('.md'));


prepareImageFiles(imageFiles, outputFolder);
prepareMarkdownFiles(markdownFiles, outputFolder);
