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

var addOnlyOfficeButton = function(formats, attachmentsDiskFilename, isConvert, pageId, pageType) {
    if (document.getElementsByClassName("attachments")[0] != null) {
        var attachmentsTable = document.getElementsByClassName("attachments")[0].children[1];
        var attachmentsList = attachmentsTable.children[0].children;

        for (var i = 0; i < attachmentsList.length; i++) {
            var ext = attachmentsDiskFilename[i].substring(attachmentsDiskFilename[i].lastIndexOf("."));
            if (formats.indexOf(ext) !== -1) {
                var editorButton = addConvertOrEditorButton(true, i);

                let attachmentHref = attachmentsList[i].children[0].children[0].href;
                let attachmentId = attachmentHref.substring(attachmentHref.lastIndexOf("/"));
                editorButton.href = "#";
                editorButton.onclick = function () {
                    window.open(window.location.origin + "/onlyoffice/editor" + attachmentId);
                    window.location.reload();
                }
                var convertButton = null;
                if (isConvert[i]) {
                    convertButton = addConvertOrEditorButton(false, i);
                    convertButton.href = window.location.origin + "/onlyoffice/conversion/" + pageId + "/" + pageType + attachmentId;
                }
                var deleteButton = attachmentsList[i].children[attachmentsList[i].children.length - 1].getElementsByClassName("delete icon-only icon-del")[0];
                if (!!deleteButton) {
                    attachmentsList[i].children[attachmentsList[i].children.length - 1].insertBefore(editorButton, deleteButton);
                    if (convertButton != null) {
                        attachmentsList[i].children[attachmentsList[i].children.length - 1].insertBefore(convertButton, deleteButton);
                    }
                } else {
                    attachmentsList[i].children[attachmentsList[i].children.length - 1].appendChild(editorButton);
                    if (convertButton != null) {
                        attachmentsList[i].children[attachmentsList[i].children.length - 1].appendChild(convertButton);
                    }
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

var addConvertOrEditorButton = function(forEditor, index) {
    var button = document.createElement("a");
    button.id = (forEditor ? "onlyoffice-button-" : "onlyoffice-button-convert-") + index;
    button.className = forEditor ? "onlyoffice-editor-button icon-only" : "onlyoffice-editor-button-convert icon-only";
    button.style.backgroundImage = forEditor ? 'url(/plugin_assets/onlyoffice_redmine/images/onlyoffice.ico)' : 'url(/plugin_assets/onlyoffice_redmine/images/conversion.svg)';
    button.style.backgroundSize = "16px";
    button.style.margin = forEditor ? "0 6px" : "0 6px 0 0";
    return button;
}
