resource "<TYPE>" "<LABEL>" {
    <PROVIDER_ARGUMENTS>
    count = <NUMBER>      # `for_each` and `count` are mutually exclusive
    depends_on = [ <RESOURCE.ADDRESS.EXPRESSION> ]
    for_each = {          # `for_each` and `count` are mutually exclusive
        <KEY> = <VALUE>
    }
    for_each = [       # `for_each` accepts a map or a set of strings
        "<VALUE>",
        "<VALUE>"
    ]
    provider = <REFERENCE.TO.ALIAS>
    lifecycle {
        action_trigger {
        events = [        # specify one or more lifecycle events as a list 
            before_create, 
            after_create,
            before_update,
            after_update
        ]
        condition = <EXPRESSSION>
        actions = [ action.<TYPE>.<LABEL> ]
        }
        create_before_destroy = <true || false>
        prevent_destroy = <true || false>
        ignore_changes = [ <ATTRIBUTE> ]
        replace_triggered_by = [ <RESOURCE.ADDRESS.EXPRESSION> ]
        precondition {
        condition = <EXPRESSION>
        error_message = "<STRING>"
        }
        postcondition {
        condition = <EXPRESSION>
        error_message = "<STRING>"
        }
    }
    connection {
        type = <"ssh" or "winrm">
        host = <EXPRESSION>
        <DEFAULT_CONNECTION_SETTINGS>
    }
    provisioner "<TYPE>" {
        source = "<PATH>"
        destination = "<PATH>"
        content = "<CONTENT TO COPY TO `destination`>"
        command = <COMMAND>
        working_dir = "<PATH TO DIR WHERE TERRAFORM EXECUTES `command`>"
        interpreter = [
        "<PATH TO INTERPRETER EXECUTABLE>",
        "<COMMAND> <ARGUMENTS>"
        ]
        environment {
        "<KEY>" = "<VALUE>"
        }
        when = <TERRAFORM COMMAND>
        quiet = <true || false>
        inline = [ "<COMMAND>" ]
        script = "<PATH>"
        scripts = [
        "<PATH>"
        ]
        on_failure = <continue || fail>
        connection {
        type = <"ssh" or "winrm">
        host = <EXPRESSION>
        <SPECIFIC_CONNECTION_SETTINGS>
        }
    }
    }