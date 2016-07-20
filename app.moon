lapis = require "lapis"

import respond_to, json_params from require "lapis.application"

Users = require "models.Users"
sandbox = require "lib.sandbox"

class extends lapis.Application
	[githook: "/githook"]: respond_to {
        GET: =>
            return status: 404
        POST: json_params =>
            if @params.ref == "refs/heads/master"
                os.execute "echo \"Updating server...\" >> logs/updates.log"
                os.execute "git pull origin >> logs/updates.log"
                os.execute "moonc . 2>> logs/updates.log"
                os.execute "ldoc . >> logs/updates.log"
                os.execute "lapis migrate production >> logs/updates.log"
                os.execute "lapis build production >> logs/updates.log"
                return { json: { status: "successful" } } --TODO scan for actual success (exit codes?), return a server error or whatever for errors
            else
                return { json: { status: "ignored non-master push" } }
    }

    [index: "/"]: =>
    	@html ->
    		ul ->
	    		if @session.id
	    			li ->
	    				a href: @url_for("logout"), "Log out!"
	    		else
		    		li ->
    		    		a href: @url_for("create_user"), "Make an account."
    				li ->
    					a href: @url_for("login"), "Log in!"

    [create_user: "/create_user"]: respond_to {
    	GET: =>
    		@html ->
    			form {
    				action: "/create_user",
    				method: "POST",
    				enctype: "multipart/form-data"
    			}, ->
    				p "Username: "
    				input type: "text", name: "user"
    				p "Password: "
    				input type: "password", name: "password"
    				br!
    				input type: "submit"
    	POST: =>
			user, errMsg = Users\create {
				name: @params.user
				password: @params.password
			}
			if user
				@session.id = user.id
				return redirect_to: @url_for "index"
			else
				return errMsg
    }

    [login: "/login"]: respond_to {
    	GET: =>
    		@html ->
    			form {
    				action: "/login"
    				method: "POST"
    				enctype: "multipart/form-data"
    			}, ->
    				p "Username: "
    				input type: "text", name: "user"
    				p "Password: "
    				input type: "password", name: "password"
    				br!
    				input type: "submit"
    	POST: =>
			if user = Users\find name: @params.user
				if user.password == @params.password
					@session.id = user.id
    		return redirect_to: @url_for "index"
    }

    [logout: "/logout"]: =>
    	@session.id = nil
    	return redirect_to: @url_for "index"

    --NOTE this is temporary
    [execute: "/execute"]: respond_to {
        GET: =>
            @html ->
                form {
                    action: "/execute"
                    method: "POST"
                    enctype: "multipart/form-data"
                }, ->
                    textarea rows: "7", cols: "45", name: "code"
                    br!
                    input type: "submit"
        POST: =>
            out = ""
            print = (...) ->
                -- for every arg, put in out
                for n = 1, select("#", ...)
                    out ..= select n, ...
                out ..= "\n"

            lomeli = ->
                error "Fuck off Lomeli!"

            ok, result = pcall sandbox.run, @params.code, {quota: 2000, env: { :print, :lomeli }}
            @html ->
                if ok
                    pre style: "color:green;", result
                else
                    pre style: "color:red;", result
                pre out
    }
