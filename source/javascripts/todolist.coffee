class Task extends Spine.Model
    @configure "Task", "name", "done"

    @extend Spine.Model.Local

    @active: ->
        @select (item)-> !item.done

    @done: ->
        @select (item)-> !!item.done

    @clearDone: ->
        rec.destroy() for rec in @done()

    toggle: ->
        @updateAttribute "done", !@done


class TaskApp extends Spine.Controller
    events:
        "keypress #input": "check_input_keypress"
        "click .clear": "clearDone"

    elements:
        "#input": "input"
        ".tasks": "tasks"
        ".remain .num": "remainNumber"

    constructor: ->
        super
        Task.bind "create", @addOne
        Task.bind "refresh", @addAll
        Task.bind "destroy", @checkRemain
        Task.bind "create", @checkRemain
        Task.bind "update", @checkRemain

        @input.focus()

    check_input_keypress: (e)->
        return unless e.keyCode == 13
        val = @input.val().trim()
        return unless val

        task = Task.create name: val
        @input.val("")

    addOne: (task)=>
        view = new Tasks(item: task)
        el = view.render().el.hide().fadeIn(300)
        @tasks.prepend(el)

    addAll: =>
        @tasks.clear()
        Task.each @addOne

    checkRemain: =>
        remains = Task.active().length
        @remainNumber.text(remains)

    clearDone: =>
        Task.clearDone()

class Tasks extends Spine.Controller
    events:
        "click .checkbox": "toggle"
        "dblclick .name": "enterEdit"
        "blur .edit": "leaveEdit"
        "keypress .edit": "keyEdit"
        "click .delete": "onDelete"

    elements:
        "input.edit": "edit"

    constructor: ->
        super
        @item.bind "update", @render
        @item.bind "destroy", @release

    render: =>
        @replace $('#taskTemplate').tmpl(@item)
        @

    toggle: =>
        @item.toggle()

    enterEdit: =>
        @el.addClass('editing')
        @edit.focus()

    keyEdit: (e)=>
        return unless e.keyCode == 13
        @leaveEdit()

    leaveEdit: =>
        @item.updateAttribute "name", @edit.attr('value')
        @el.removeClass('editing')

    onDelete: =>
        @item.destroy()

    release: =>
        @el.fadeOut(300, =>@el.remove())

window.TaskApp = TaskApp
window.Task = Task
window.Tasks = Tasks