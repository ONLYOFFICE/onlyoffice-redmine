(function () {
    if (!window.ONLYOFFICE) ONLYOFFICE = {};
    if (!window.ONLYOFFICE.Buttons) ONLYOFFICE.Buttons = {};

    function createConvertButton(is_edit, text, image) {
        var downloadButton = document.getElementsByClassName("contextual")[0].getElementsByClassName("icon icon-download")[0];
        var button = document.createElement("a");

        button.innerText = text;
        button.className = "onlyoffice-editor-button icon";
        button.style.backgroundImage = image;
        button.style.backgroundSize = "16px";
        button.style.cursor = "pointer";

        if (is_edit) {
            let attachmentHref = window.location.href;
            button.onclick = function () {
                window.open(window.location.origin + "/onlyoffice/editor" + attachmentHref.substring(attachmentHref.lastIndexOf("/")));
                window.location.reload();
            }
        } else {
            button.href = "#";
            button.onclick = function () {
                ONLYOFFICE.Convert.displayFormDownloadAs();
            }
        }
        downloadButton.parentElement.insertBefore(button, downloadButton);
    }

    ONLYOFFICE.Buttons.createConvertButton = createConvertButton;
})();