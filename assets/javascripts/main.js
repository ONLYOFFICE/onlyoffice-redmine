//
// (c) Copyright Ascensio System SIA 2023
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @ts-check

(async function () {
  "use strict"

  /**
   * @returns {void}
   */
  function main() {
    window.addEventListener("DOMContentLoaded", setup)
  }

  /**
   * @returns {Promise<void>}
   */
  async function setup() {
    if (AttachmentsShow.rendered()) {
      AttachmentsShow.setup()
      return
    }
    if (DocumentsShow.rendered()) {
      DocumentsShow.setup()
      return
    }
    if (FilesIndex.rendered()) {
      FilesIndex.setup()
      return
    }
    if (IssuesShow.rendered()) {
      IssuesShow.setup()
      return
    }
    if (NewsShow.rendered()) {
      NewsShow.setup()
      return
    }
    if (OnlyOfficeEditor.rendered()) {
      OnlyOfficeEditor.setup()
      return
    }
    if (OnlyOfficeConvert.rendered()) {
      OnlyOfficeConvert.setup()
      return
    }
    if (OnlyOfficeNew.rendered()) {
      OnlyOfficeNew.setup()
      return
    }
    if (Settings.rendered()) {
      Settings.setup()
      return
    }
    if (WikiShow.rendered()) {
      WikiShow.setup()
      return
    }
  }

  // Views

  /**
   * [Local Reference](../../app/views/attachments/show.rb)
   */
  const AttachmentsShow = {
    /**
     * @returns {boolean}
     */
    rendered() {
      return rendered("attachments", "show")
    },

    /**
     * @returns {void}
     */
    setup() {
      // https://github.com/redmine/redmine/blob/5.0.0/app/views/attachments/_links.html.erb#L2
      const contextual = document.querySelector("#content > .contextual")
      if (!contextual || !(contextual instanceof HTMLElement)) return

      const convert = document.querySelector("#onlyoffice-convert")
      if (convert && (convert instanceof HTMLTemplateElement)) {
        this.inject(convert, contextual)
      }

      const view = document.querySelector("#onlyoffice-view")
      if (view && (view instanceof HTMLTemplateElement)) {
        this.inject(view, contextual)
      }

      const edit = document.querySelector("#onlyoffice-edit")
      if (edit && (edit instanceof HTMLTemplateElement)) {
        this.inject(edit, contextual)
      }
    },

    /**
     * @param {HTMLTemplateElement} template
     * @param {HTMLElement} container
     * @returns {void}
     */
    inject(template, container) {
      const clone = template.content.cloneNode(true)
      container.prepend(clone)
    }
  }

  /**
   * [Local Reference](../../app/views/documents/show.rb)
   */
  const DocumentsShow = {
    /**
     * @returns {boolean}
     */
    rendered() {
      return rendered("documents", "show")
    },

    /**
     * @returns {void}
     */
    setup() {
      this.setupAttachments()
      this.setupNew()
    },

    /**
     * @returns {void}
     */
    setupAttachments() {
      const containers = Attachments.containers()
      Attachments.setup(containers)
    },

    /**
     * @returns {void}
     */
    setupNew() {
      const template = document.querySelector("#onlyoffice-new")
      if (!template || !(template instanceof HTMLTemplateElement)) return

      const clone = template.content.cloneNode(true)
      if (!(clone instanceof DocumentFragment)) return

      // https://github.com/redmine/redmine/blob/5.0.0/app/views/documents/show.html.erb#L31
      const sibling = document.querySelector("#attach_files_link")
      if (!sibling) return

      sibling.after(clone)
    }
  }

  /**
   * [Local Reference](../../app/views/files/index.rb)
   */
  const FilesIndex = {
    /**
     * @returns {boolean}
     */
    rendered() {
      return rendered("files", "index")
    },

    /**
     * @returns {void}
     */
    setup() {
      // https://github.com/redmine/redmine/blob/5.0.0/app/views/files/index.html.erb#L36
      const containers = document.querySelectorAll(".files .buttons")
      Attachments.setup(containers)
    }
  }

  /**
   * [Local Reference](../../app/views/issues/show.rb)
   */
  const IssuesShow = {
    /**
     * @returns {boolean}
     */
    rendered() {
      return rendered("issues", "show")
    },

    /**
     * @returns {void}
     */
    setup() {
      const containers = Attachments.containers()
      Attachments.setup(containers)
    }
  }

  /**
   * [Local Reference](../../app/views/news/show.rb)
   */
  const NewsShow = {
    /**
     * @returns {boolean}
     */
    rendered() {
      return rendered("news", "show")
    },

    /**
     * @returns {void}
     */
    setup() {
      const containers = Attachments.containers()
      Attachments.setup(containers)
    }
  }

  /**
   * [Local Reference](../../app/views/wiki/show.rb)
   */
  const WikiShow = {
    /**
     * @returns {boolean}
     */
    rendered() {
      return rendered("wiki", "show")
    },

    /**
     * @returns {void}
     */
    setup() {
      const containers = Attachments.containers()
      Attachments.setup(containers)
    }
  }

  /**
   * [Local Reference](../../app/views/onlyoffice/editor.rb)
   */
  const OnlyOfficeEditor = {
    /**
     * @type {string | undefined}
     */
    saveAsUrl: undefined,

    /**
     * @returns {boolean}
     */
    rendered() {
      return (
        rendered("only_office_attachments", "view") ||
        rendered("only_office_attachments", "edit")
      )
    },

    /**
     * @returns {void}
     */
    setup() {
      const editor = document.querySelector(".onlyoffice-editor")
      if (!editor || !(editor instanceof HTMLElement)) return

      if (!window.DocsAPI || !editor.dataset.documentServerConfig) {
        const error = document.querySelector(".flash.onlyoffice.error.hidden")
        if (!error) return

        // To display the error normally, we should remove our custom styles.
        // See `main.css`.
        document.body.dataset.editorError = ""

        error.classList.remove("hidden")
        return
      }

      if (editor.dataset.title) {
        document.title = editor.dataset.title
      }
      if (editor.dataset.faviconUrl) {
        replaceFavicon(editor.dataset.faviconUrl)
      }
      if (editor.dataset.saveAsUrl) {
        this.saveAsUrl = editor.dataset.saveAsUrl
      }

      const config = JSON.parse(editor.dataset.documentServerConfig)
      config.event = {
        "onError": this.onError,
        "onRequestSaveAs": this.onRequestSaveAs
      }
      config.height = "100%"
      config.type = deviceType()
      config.width = "100%"

      const _ = new window.DocsAPI.DocEditor("onlyoffice-editor-placeholder", config)
    },

    /**
     * [OnlyOffice Reference](https://api.onlyoffice.com/editors/config/events#onError)
     *
     * @param {any} event
     * @returns {void}
     */
    onError(event) {
      console.error(event.data)
    },

    /**
     * [OnlyOffice Reference](https://api.onlyoffice.com/editors/config/events#onRequestSaveAs)
     *
     * @param {any} event
     * @returns {Promise<void>}
     */
    async onRequestSaveAs(event) {
      if (!this.saveAsUrl) return
      const payload = {
        url: event.data.url,
        title: event.data.title
      }
      await fetch(this.saveAsUrl, {
        method: "POST",
        body: JSON.stringify(payload)
      })
    }
  }

  /**
   * @typedef {Object} ConvertResult
   * @property {number=} percent
   * @property {string=} url
   */

  /**
   * [Local Reference](../../app/views/onlyoffice/convert.rb)
   */
  const OnlyOfficeConvert = {
    /**
     * @returns {boolean}
     */
    rendered() {
      return rendered("only_office_attachments", "convert")
    },

    /**
     * @returns {void}
     */
    setup() {
      this.setupForm()
    },

    /**
     * @returns {void}
     */
    setupForm() {
      const form = document.querySelector("#content form")
      if (!form || !(form instanceof HTMLFormElement)) return
      form.addEventListener("submit", this.submit.bind(this))
    },

    /**
     * @param {SubmitEvent} event
     * @returns {Promise<void>}
     */
    async submit(event) {
      event.preventDefault()

      const form = event.currentTarget
      if (!form || !(form instanceof HTMLFormElement)) return

      if (!event.submitter || !event.submitter.dataset.url) return

      const data = new FormData(form)

      this.disableSubmitters(form)
      Progress.reset(form)
      await this.subscribe(form, event.submitter.dataset.url, data)
    },

    /**
     * @param {HTMLFormElement} form
     * @param {string} url
     * @param {FormData} data
     * @returns {Promise<void>}
     */
    async subscribe(form, url, data) {
      const response = await fetch(url, {
        method: form.method,
        body: data,
        redirect: "manual"
      })

      const type = response.headers.get("Content-Type")
      if (type && type.includes("application/json")) {
        /** @type ConvertResult */
        const result = await response.json()

        if (result.percent != null) {
          Progress.update(form, result.percent)
          await wait(1000)
          await this.subscribe(form, url, data)
          return
        }

        if (result.url) {
          download(result.url)
        }
      }

      window.location.reload()
    },

    /**
     * @param {HTMLFormElement} form
     * @returns {void}
     */
    disableSubmitters(form) {
      this.toggleSubmitters(form, true)
    },

    /**
     * @param {HTMLFormElement} form
     * @returns {void}
     */
    enableSubmitters(form) {
      this.toggleSubmitters(form, false)
    },

    /**
     * @param {HTMLFormElement} form
     * @param {Boolean} disabled
     * @returns {void}
     */
    toggleSubmitters(form, disabled) {
      const inputs = form.querySelectorAll("input[type='submit'")
      inputs.forEach((input) => {
        if (!(input instanceof HTMLInputElement)) return
        input.disabled = disabled
      })
    }
  }

  /**
   * [Local Reference](../../app/views/onlyoffice/new.rb)
   */
  const OnlyOfficeNew = {
    /**
     * @type {((this: OnlyOfficeNew, event: SubmitEvent) => void) | undefined}
     */
    listener: undefined,

    /**
     * @returns {boolean}
     */
    rendered() {
      return rendered("onlyoffice_create", "new")
    },

    /**
     * @returns {void}
     */
    setup() {
      const form = document.querySelector("#content form")
      if (!form || !(form instanceof HTMLFormElement)) return

      this.listener = this.submit.bind(this)
      if (!this.listener) return

      form.addEventListener("submit", this.listener)
    },

    /**
     * @param {SubmitEvent} event
     * @returns {void}
     */
    submit(event) {
      event.preventDefault()

      const form = event.currentTarget
      if (!form || !(form instanceof HTMLFormElement)) return

      if (!this.listener) return
      form.removeEventListener("submit", this.listener)

      const typeSelect = form.querySelector("#onlyoffice-type")
      if (!typeSelect || !(typeSelect instanceof HTMLSelectElement)) return

      const typeOption = typeSelect.selectedOptions[0]
      if (!typeOption.dataset.action) return

      form.action = typeOption.dataset.action
      form.submit()
    }
  }

  /**
   * [Local Reference](../../app/views/settings/plugin.rb)
   */
  const Settings = {
    /**
     * @returns {boolean}
     */
    rendered() {
      return rendered("settings", "plugin")
    },

    /**
     * @returns {void}
     */
    setup() {
      const settings = document.querySelector(".onlyoffice-settings")
      if (
        !settings ||
        !(settings instanceof HTMLElement) ||
        !settings.dataset.action
      ) return

      this.setupForm(settings.dataset.action)
      this.setupContainer(settings)
      this.setupTrial(settings)
    },

    /**
     * @param {string} action
     * @returns {void}
     */
    setupForm(action) {
      // https://github.com/redmine/redmine/blob/5.0.0/app/views/settings/plugin.html.erb#L4
      const form = document.querySelector("#settings > form")
      if (!form || !(form instanceof HTMLFormElement)) return
      form.action = action
    },

    /**
     * Removes classes from the container so that the sections have a
     * transparent background.
     *
     * [Redmine Reference: View](https://github.com/redmine/redmine/blob/5.0.0/app/views/settings/plugin.html.erb#L5)
     *
     * @param {HTMLElement} settings
     * @returns {void}
     */
    setupContainer(settings) {
      const container = settings.parentElement
      if (!container) return
      container.removeAttribute("class")
    },

    /**
     * @param {HTMLElement} settings
     * @returns {void}
     */
    setupTrial(settings) {
      const input = settings.querySelector("#onlyoffice-trial-enabled")
      if (!input || !(input instanceof HTMLInputElement) || !input.form) return

      if (input.checked) {
        this.toggleTrial(input.form, true)
      }

      input.addEventListener("change", this.changeTrial.bind(this))
    },

    /**
     * @param {Event} event
     * @returns {void}
     */
    changeTrial(event) {
      const input = event.target
      if (!input || !(input instanceof HTMLInputElement) || !input.form) return
      this.toggleTrial(input.form, input.checked)
    },

    /**
     * @param {HTMLElement} form
     * @param {boolean} disabled
     * @returns {void}
     */
    toggleTrial(form, disabled) {
      const inputs = form.querySelectorAll("input[data-disabled-for-trial]")
      inputs.forEach((input) => {
        if (!(input instanceof HTMLInputElement)) return
        input.disabled = disabled
      })
    }
  }

  // Blocks

  /**
   * @typedef {Attachment[]} AttachmentsData
   */

  /**
   * @typedef {Object} Attachment
   * @property {number} index
   * @property {string=} view_url
   * @property {string=} edit_url
   * @property {string=} convert_url
   */

  /**
   * [Local Reference](../../app/views/_blocks/attachments.rb)
   */
  const Attachments = {
    /**
     * @returns {NodeListOf<Element>}
     */
    containers() {
      // https://github.com/redmine/redmine/blob/5.0.0/app/views/attachments/_links.html.erb#L28
      return document.querySelectorAll(".attachments tr > :last-child")
    },

    /**
     * @param {NodeListOf<Element>} containers
     * @returns {void}
     */
    setup(containers) {
      const attachments = this.attachments()
      const view = document.querySelector("#onlyoffice-view")
      const edit = document.querySelector("#onlyoffice-edit")
      const convert = document.querySelector("#onlyoffice-convert")

      attachments.forEach((attachment) => {
        const viewURL = attachment["view_url"]
        const editURL = attachment["edit_url"]
        const convertURL = attachment["convert_url"]

        const container = containers[attachment.index]
        if (!container || !(container instanceof HTMLElement)) return

        if (convert && convert instanceof HTMLTemplateElement && convertURL) {
          this.inject(convert, convertURL, container)
        }

        if (view && view instanceof HTMLTemplateElement && viewURL) {
          this.inject(view, viewURL, container)
        }

        if (edit && edit instanceof HTMLTemplateElement && editURL) {
          this.inject(edit, editURL, container)
        }
      })
    },

    /**
     * @returns {AttachmentsData}
     */
    attachments() {
      const template = document.querySelector("#onlyoffice-attachments")
      if (
        !template ||
        !(template instanceof HTMLTemplateElement) ||
        !template.dataset.attachments
      ) {
        return []
      }
      return JSON.parse(template.dataset.attachments)
    },

    /**
     * @param {HTMLTemplateElement} template
     * @param {string} url
     * @param {HTMLElement} container
     * @returns {void}
     */
    inject(template, url, container) {
      const fragment = template.content.cloneNode(true)
      if (!(fragment instanceof DocumentFragment)) return

      const anchor = fragment.querySelector("a")
      if (!anchor) return

      anchor.href = url

      // Redmine uses a whitespace to separate action anchors.
      container.prepend(fragment, "")
    }
  }

  /**
   * [Local Reference](../../app/views/_blocks/progress.mustache) \
   * [Redmine Reference: Helper](https://github.com/redmine/redmine/blob/5.0.0/app/helpers/application_helper.rb#L1561)
   */
  const Progress = {
    /**
     * @param {HTMLElement} container
     * @returns {void}
     */
    reset(container) {
      this.update(container, 0)
    },

    /**
     * @param {HTMLElement} container
     * @param {number} done
     * @returns {void}
     */
    update(container, done) {
      const closed = container.querySelector(".progress .closed")
      if (!closed || !(closed instanceof HTMLElement)) return

      const todo = container.querySelector(".progress .todo")
      if (!todo || !(todo instanceof HTMLElement)) return

      const percent = container.querySelector(".percent")
      if (!percent) return

      closed.style.width = `${done}%`
      todo.style.width = `${done - 100}%`
      percent.textContent = closed.style.width

      switch (done) {
        case 0:
          closed.classList.add("hidden")
          todo.classList.remove("hidden")
          return
        case 100:
          closed.classList.remove("hidden")
          todo.classList.add("hidden")
          return
        default:
          closed.classList.remove("hidden")
          todo.classList.remove("hidden")
      }
    }
  }

  /**
   * [Redmine Reference: View](https://github.com/redmine/redmine/blob/5.0.0/app/views/layouts/base.html.erb#L111) \
   * [Redmine Reference: Helper](https://github.com/redmine/redmine/blob/5.0.0/app/helpers/application_helper.rb#L481)
   */
  const Flash = {
    /**
     * @returns {void}
     */
    setup() {
      const heading = document.querySelector("#content h2")
      if (!heading) return

      const container = document.createElement("div")
      container.id = "onlyoffice-flash"
      container.classList.add("hidden")

      heading.after(container)
    },

    /**
     * @param {string} message
     * @returns {void}
     */
    error(message) {
      this.show("error", message)
    },

    /**
     * @param {string} message
     * @returns {void}
     */
    notice(message) {
      this.show("notice", message)
    },

    /**
     * @param {"error" | "notice"} type
     * @param {string} message
     * @returns {void}
     */
    show(type, message) {
      const container = document.querySelector("#onlyoffice-flash")
      if (!container) return

      const flash = document.createElement("div")
      flash.classList.add("flash", type)
      flash.textContent = message

      container.classList.remove("hidden")
      container.append(flash)
    },

    /**
     * @returns {void}
     */
    hide() {
      const container = document.querySelector("#onlyoffice-flash")
      if (!container) return
      container.innerHTML = ""
    }
  }

  // Functions

  /**
   * [Redmine Reference: View](https://github.com/redmine/redmine/blob/5.0.0/app/views/layouts/base.html.erb#L21) \
   * [Redmine Reference: Helper](https://github.com/redmine/redmine/blob/5.0.0/app/helpers/application_helper.rb#L813)
   *
   * @param {string} controller
   * @param {string} action
   * @returns {boolean}
   */
  function rendered(controller, action) {
    return (
      document.body.classList.contains(`controller-${controller}`) &&
      document.body.classList.contains(`action-${action}`)
    )
  }

  /**
   * @param {string} url
   * @returns {void}
   */
  function download(url) {
    const anchor = document.createElement("a")
    anchor.classList.add("hidden")
    anchor.href = url
    anchor.target = "_blank"
    document.body.append(anchor)
    anchor.click()
    anchor.remove()
  }

  /**
   * @param {number} milliseconds
   * @returns {Promise<void>}
   */
  function wait(milliseconds) {
    return new Promise((resolve) => {
      setTimeout(resolve, milliseconds)
    })
  }

  /**
   * [Redmine Reference: View](https://github.com/redmine/redmine/blob/5.0.0/app/views/layouts/base.html.erb#L11) \
   * [Redmine Reference: Helper](https://github.com/redmine/redmine/blob/5.0.0/app/helpers/application_helper.rb#L1741)
   *
   * @param {string} href
   * @returns {void}
   */
  function replaceFavicon(href) {
    const icon = document.head.querySelector("link[rel='shortcut icon']")
    if (!icon || !(icon instanceof HTMLLinkElement)) return
    icon.href = href
  }

  /**
   * [Habr Reference](https://habr.com/en/sandbox/163605)
   *
   * @returns {"mobile" | "desktop"}
   */
  function deviceType() {
    if (window.matchMedia("(pointer: coarse)").matches) {
      return "mobile"
    }
    return "desktop"
  }

  /**
   * @param {string | null | undefined} message
   * @returns {string}
   */
  function shrugify(message) {
    return message || "Error occurred in the document service. Please contact admin"
  }

  // Main

  main()
})()
