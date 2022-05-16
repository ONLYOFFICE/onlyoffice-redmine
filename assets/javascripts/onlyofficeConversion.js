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
        type: $('#type')[0].value, 
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
            var responseText = result.responseText;
            try {
                var response = $.parseJSON(responseText);
            } catch (e) {
                isDisable(false);
                showNotice('error');
                return;
            }
            if (response.percent < 100) {
                data.type = $('#type')[0].value;
                form.submit();
            } else if (response.percent >= 100) {
                isDisable(false);
                $('#progress')[0].style.setProperty('--percent', response.percent + '%')
                bar.innerText = response.percent + "%";
                showNotice('success');
                if (back_page == undefined) {
                    displayFormDownloadAs(false);
                }
            }
        });
    }
    _callAjax();
}

var displayFormDownloadAs = function (bool) {
    if (bool) {
        resetForm();

        $("#donwload_as")[0].style.display = "block";
        $("body")[0].style.background = "#000";
        $("#wrapper")[0].style = "background: #000; opacity: 70%;";

        var form = $('#conversion')[0];

        form.addEventListener("submit", function (event) {
            isDisable(true);
            showProgress(true);
            event.preventDefault();
            sendSubmit();
        }, false );
    } else {
        $("#donwload_as")[0].style.display = "none";
        $("body")[0].style.background = "none";
        $("#wrapper")[0].style = "background: none; opacity: 100%;";
    }
}

var resetForm = function () {
    $('form select')[0].firstChild.selected = true;
}