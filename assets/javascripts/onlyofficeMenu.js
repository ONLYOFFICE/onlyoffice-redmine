/**
 *
 * (c) Copyright Ascensio System SIA 2022
 * http://www.onlyoffice.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

var addOnlyOfficeButton = function(formats, attachmentsDiskFilename) {
    if (document.getElementsByClassName("attachments")[0] != null) {
        var attachmentsTable = document.getElementsByClassName("attachments")[0].children[1];
        var attachmentsList = attachmentsTable.children[0].children;

        for (var i = 0; i < attachmentsList.length; i++) {
            var ext = attachmentsDiskFilename[i].substring(attachmentsDiskFilename[i].lastIndexOf("."));
            if (formats.indexOf(ext) !== -1) {
                var editorButton = document.createElement("a");

                editorButton.id = "onlyoffice-button-" + i;
                editorButton.className = "onlyoffice-editor-button icon-only";
                editorButton.style.backgroundImage = 'url(/plugin_assets/onlyoffice_redmine/images/onlyoffice.ico)';
                editorButton.style.backgroundSize = "16px";
                editorButton.style.margin = "0 6px";

                let attachmentHref = attachmentsList[i].children[0].children[0].href;
                editorButton.href = "#";
                editorButton.onclick = function () {
                    window.open(window.location.origin + "/onlyoffice/editor" + attachmentHref.substring(attachmentHref.lastIndexOf("/")));
                    window.location.reload();
                }
                var deleteButton = attachmentsList[i].children[attachmentsList[i].children.length - 1].getElementsByClassName("delete icon-only icon-del")[0];
                if (!!deleteButton) {
                    attachmentsList[i].children[attachmentsList[i].children.length - 1].insertBefore(editorButton, deleteButton);
                } else {
                    attachmentsList[i].children[attachmentsList[i].children.length - 1].appendChild(editorButton);
                }
            }
        }
    }
}

var addOnlyOfficeCreateButton = function(containerElement) {
    var dropdown = document.getElementById("onlyoffice-create-dropdown");
    if (containerElement != null && dropdown != null) {
        containerElement.appendChild(dropdown);
        dropdown.classList.remove("hidden");
    }
}

var addOnlyOfficeConvert = function(formats, attachmentsDiskFilename, pageId, pageType) {
    if (document.getElementsByClassName("attachments")[0] != null) {
        var attachmentsTable = document.getElementsByClassName("attachments")[0].children[1];
        var attachmentsList = attachmentsTable.children[0].children;

        for (var i = 0; i < attachmentsList.length; i++) {
            var ext = attachmentsDiskFilename[i].substring(attachmentsDiskFilename[i].lastIndexOf("."));
            if (formats.indexOf(ext) !== -1) {
                var convertButton = document.createElement("a");

                convertButton.id = "onlyoffice-button-convert-" + i;
                convertButton.className = "onlyoffice-editor-button-convert icon-only";
                convertButton.style.backgroundImage = 'url(/plugin_assets/onlyoffice_redmine/images/conversion.svg)';
                convertButton.style.backgroundSize = "16px";
                convertButton.style.margin = "0 6px";

                let attachmentHref = attachmentsList[i].children[0].children[0].href;
                convertButton.href = "#";
                convertButton.onclick = function () {
                    window.location.replace(window.location.origin + "/onlyoffice/conversion/"+ pageId + "/" + pageType + attachmentHref.substring(attachmentHref.lastIndexOf("/")));
                }
                var deleteButton = attachmentsList[i].children[attachmentsList[i].children.length - 1].getElementsByClassName("delete icon-only icon-del")[0];
                if (!!deleteButton) {
                    attachmentsList[i].children[attachmentsList[i].children.length - 1].insertBefore(convertButton, deleteButton);
                } else {
                    attachmentsList[i].children[attachmentsList[i].children.length - 1].appendChild(convertButton);
                }
            }
        }
    } else if (document.getElementsByTagName("tbody")[0] != null) {
        attachmentsList = document.getElementsByTagName("tbody")[0].children;
        for (var i = 0; i < attachmentsList.length; i++) {
            var filename = attachmentsDiskFilename[i].firstChild.innerText;
            var ext = filename.substring(filename.lastIndexOf("."));
            if (formats.indexOf(ext) !== -1) {
                var convertButton = document.createElement("a");

                convertButton.id = "onlyoffice-button-convert-" + i;
                convertButton.className = "onlyoffice-editor-button-convert icon-only";
                convertButton.style.backgroundImage = 'url(/plugin_assets/onlyoffice_redmine/images/conversion.svg)';
                convertButton.style.backgroundSize = "16px";
                convertButton.style.margin = "0 6px";

                let attachmentHref = document.getElementsByClassName("icon-only icon-del")[i].href;
                convertButton.href = "#";
                convertButton.onclick = function () {
                    window.location.replace(window.location.origin + "/onlyoffice/conversion/"+ pageId + "/" + pageType + attachmentHref.substring(attachmentHref.lastIndexOf("/")));
                }
                var downloadButton = document.getElementsByClassName("icon-only icon-download")[i];
                if (!!downloadButton) {
                    attachmentsList[i].children[attachmentsList[i].children.length - 1].insertBefore(convertButton, downloadButton);
                } else {
                    attachmentsList[i].children[attachmentsList[i].children.length - 1].appendChild(convertButton);
                }
            }
        }
    }
}