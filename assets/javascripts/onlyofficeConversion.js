var showProgress = function (bool) {
    $('#progress')[0].style.setProperty('--percent', 0 + '%')
    if (bool) {
        $('#progress_bar')[0].style.display = 'flex';
    } else {
        $('#progress_bar')[0].style.display = 'none';
    }
}

var sendSubmit = function (back_page = $('#back_page')[0]) {
    var bar = $('#progress_label')[0];

    var data = {
        utf8: $('input[name = "utf8"]')[0].value,
        authenticity_token: $('input[name = "authenticity_token"]')[0].value,
        back_page: (back_page == undefined) ? '' : $('#back_page')[0].value,
        file_id: $('#file_id')[0].value, 
        page_id: $('#page_id')[0].value, 
        page_type: $('#page_type')[0].value,
        field_name: $('#field_name')[0].value,
        onlyoffice_convert_current_type: $('#onlyoffice_convert_current_type')[0].value, 
        onlyoffice_convert_end_type: $('#onlyoffice_convert_end_type')[0].value,
        type: 'ajax',
        ajax: true
    };

    function _callAjax() {
        $.ajax({
            type: 'POST',
            url: ajaxUrl,
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify(data)
        }).always(function (result) {
            try {
                var response = JSON.parse(result);
            } catch (e) {
                showNotice('error');
                return;
            }
            if (response.error) {
                showNotice('error');
                return;
            } else {
                if (response.percent) {
                    console.log(response.percent)
                    var perc = response.percent / 100;
                    if (perc > 0) {
                        $('#progress')[0].style.setProperty('--percent', response.percent + '%')
                    }
                    bar.innerHTML = response.percent + "%";
                }
                if (!response.endConvert) {
                    setTimeout(_callAjax, 1000);
                } else {
                    data.type = $('#type')[0].value;
                    form.submit();
                    setTimeout(showNotice, 1000, "success");
                    if (back_page == undefined) {
                        displayFormDownloadAs(false);
                    }
                }
            }
        });
    }
    _callAjax();
}

var displayFormDownloadAs = function (bool) {
    if (bool) {
        resetForm();
        showModal('onlyoffice-modal', '600px');

        form = $('#onlyoffice-modal #conversion')[0];

        form.addEventListener("submit", function (event) {
            isDisable(true);
            showProgress(true);
            event.preventDefault();
            sendSubmit();
        }, false );
    } else {
        $('#onlyoffice-modal').dialog("close");
    }
}

var resetForm = function () {
    $('form select')[0].firstChild.selected = true;
}