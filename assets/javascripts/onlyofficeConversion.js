(function () {
    if (!window.ONLYOFFICE) ONLYOFFICE = {};
    if (!window.ONLYOFFICE.Convert) ONLYOFFICE.Convert = {};

    var showProgress = function (bool) {
        $('#progress')[0].style.setProperty('--percent', 0 + '%')
        if (bool) {
            $('#progress_bar')[0].style.display = 'flex';
        } else {
            $('#progress_bar')[0].style.display = 'none';
        }
    }

    var sendSubmit = function () {
        var backPage = $('#back_page')[0];
        var bar = $('#progress_label')[0];

        var data = {
            file_id: $('#file_id')[0].value,
            page_id: $('#page_id')[0].value,
            page_type: $('#page_type')[0].value,
            field_name: $('#field_name')[0].value,
            onlyoffice_convert_current_type: $('#onlyoffice_convert_current_type')[0].value,
            onlyoffice_convert_end_type: $('#onlyoffice_convert_end_type')[0].value,
            type: $('#type')[0].value
        };

        function _callAjax() {
            $.ajax({
                type: 'POST',
                url: ONLYOFFICE.Convert.getAjaxUrl(),
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify(data)
            }).always(function (result) {
                try {
                    var response = JSON.parse(result);
                } catch (e) {
                    ONLYOFFICE.Convert.showNotice('error');
                    return;
                }
                if (response.error) {
                    ONLYOFFICE.Convert.showNotice('error');
                    return;
                } else {
                    if (response.percent) {
                        $('#progress')[0].style.setProperty('--percent', response.percent + '%')
                        bar.innerHTML = response.percent + "%";
                    }
                    if (response.percent && response.percent < 100) {
                        setTimeout(_callAjax, 1000);
                    }
                    if (response.url) {
                        window.location.href = response.url;
                        ONLYOFFICE.Convert.showNotice("success");
                        $('#onlyoffice-modal').dialog("close");
                    }
                }
            });
        }
        _callAjax();
    }

    var displayFormDownloadAs = function () {
        resetForm();
        showModal('onlyoffice-modal', '600px');

        form = $('#onlyoffice-modal #conversion')[0];
        addSubmitEvents(form);
    }

    var addSubmitEvents = function (form) {
        form.addEventListener("submit", function (event) {
            event.preventDefault();
            $('#onlyoffice-notification')[0].style.display = 'none';
            ONLYOFFICE.Convert.isDisable(true);
            showProgress(true);
            sendSubmit();
        }, false);
    }

    var resetForm = function () {
        $('form select')[0].firstChild.selected = true;
    }

    ONLYOFFICE.Convert.showProgress = showProgress;
    ONLYOFFICE.Convert.displayFormDownloadAs = displayFormDownloadAs;
    ONLYOFFICE.Convert.addSubmitEvents = addSubmitEvents;
})();