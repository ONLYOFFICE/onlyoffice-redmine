var addOnlyOfficeButton = function(attachmentsDiskFilename) {
    var extDocument = [".doc", ".docx", ".docm", ".dot", ".dotx", ".dotm", ".odt", ".fodt", ".ott", ".rtf",
        ".txt", ".html", ".htm", ".mht", ".xml", ".pdf", ".djvu", ".fb2", ".epub", ".xps"];
    var extCell = [".xls", ".xlsx", ".xlsm", ".xlt", ".xltx", ".xltm", ".ods", ".fods", ".ots", ".csv"];
    var extPres = [".pps", ".ppsx", ".ppsm", ".ppt", ".pptx", ".pptm", ".pot", ".potx", ".potm", ".odp", ".fodp", ".otp"];
    if (document.getElementsByClassName("attachments")[0] != null) {
        var attachmentsTable = document.getElementsByClassName("attachments")[0].children[1];
        var attachmentsList = attachmentsTable.children[0].children;

        for (var i = 0; i < attachmentsList.length; i++) {
            var ext = attachmentsDiskFilename[i].substring(attachmentsDiskFilename[i].lastIndexOf("."));
            if (extDocument.includes(ext) || extCell.includes(ext) || extPres.includes(ext)) {
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
                }
                attachmentsList[i].children[attachmentsList[i].children.length - 1].getElementsByClassName("delete icon-only icon-del")[0].before(editorButton);
            }
        }
    }
}
