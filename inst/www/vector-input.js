;(function() {

  var binding = new Shiny.InputBinding()

  function render(el) {
    var widget = $(el)

    var s     = widget.data('template')
    var templ = Handlebars.compile(s)
    var html  = templ(widget.data('context'))

    $("#" + el.id).empty().append(html)
  }

  /* Data structures:
      structured    values on client  [{name: name, value: value}, ...]
      unstructured  to/from server    {name: value, ...}
  */

  // server -> client
  function structureValues(values) {
    var structured = []
    if (Object.prototype.toString.call(values) === "[object Array]") {
      // unnamed
      values.forEach(function(o) {
        structured.push({value: o})
      })
    } else {
      // named
      for (var k in values) {
        structured.push({name: k, value: values[k]})
      }
    }
    return structured
  }

  // client -> server
  function unstructureValues(values) {
    if (values.length > 0) {
      if (values[0].hasOwnProperty("name")) {
        // named
        var unstructured = {}
        values.forEach(function(o) {
          unstructured[o.name] = o.value
        })
      } else {
        // unnamed
        var unstructured = []
        values.forEach(function(o) {
          unstructured.push(o.value)
        })
      }
    }

    return unstructured
  }

  $.extend(binding, {

    /* shiny API */
    find: function(scope) {
      return $(scope).find(".vector-input")
    },

    initialize: function(el) {
      var widget = $(el)

      widget.data( 'context'
                 , { id:          widget.attr('id')
                   , type:        widget.attr('type')
                   , nameLabel:   widget.attr('nameLabel')
                   , valueLabel:  widget.attr('valueLabel')
                   , values:      structureValues(widget.attr('values') || [])
                   }
                 )
      widget.data( 'template'
                 , document.getElementById("vector-input-template-" + widget.data('context').id).innerHTML
                 )

      // Browser event binding
      widget.on("click", "button", function(event) {
        var target = event.target.id.split("-")
          , type   = target[0]
          , id     = target[1]
          , index  = target[2]

        if (type === 'add') {
          if (widget.data('context').nameLabel === '') {
            //unnamed
            var o = {value: 0}
          } else {
            //named
            var o = { name:  "Name" + (widget.data('context').values.length + 1)
                    , value: "0"
                    }
          }
          widget.data('context').values.push(o)

        } else if (type === 'del') {
          widget.data('context').values.splice(index, 1)
        }

        widget.trigger("change")
        render(el)

        event.preventDefault()
      })

      widget.on("keyup", "input", function(event) {
        var target = event.target.id.split("-")
          , type   = target[0]
          , id     = target[1]
          , index  = target[2]

        widget.data('context').values[index][type] = event.target.value
        widget.trigger("change")

        return true
      })

      render(el)
    },

    getValue: function(el) {
      return unstructureValues($(el).data('context').values)
    },

    receiveMessage: function(el, data) {
      this.setValue(el, structureValues(data.values))
    },

    setValue: function(el, value) {
      var widget = $(el)

      widget.data('context').values = value
      render(el)

      widget.trigger('change')
    },

    subscribe: function(el, callback) {
      $(el).on("change.vectorInputBinding", function(e) {
          callback()
      })
    },

    unsubscribe: function(el) {
      $(el).off(".vectorInputBinding")
    },

    getType: function(el) {
      console.log('getType called')
      return 'vectorInput.vectorInput'
    }

  })

  Shiny.inputBindings.register(binding)

})();
