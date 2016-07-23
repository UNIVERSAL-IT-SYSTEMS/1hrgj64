lapis = require "lapis"

import respond_to, json_params from require "lapis.application"

Users = require "models.Users"
sandbox = require "lib.sandbox"

class extends lapis.Application
	[githook: "/githook"]: respond_to {
        GET: =>
            return status: 405 --Method Not Allowed

        POST: json_params =>
            if @params.ref == nil
                return { json: { status: "invalid request" } }, status: 400 --Bad Request

            if @params.ref == "refs/heads/master"
                os.execute "echo \"Updating server...\" >> logs/updates.log"
                result = 0 == os.execute "git pull origin >> logs/updates.log"
                result and= 0 == os.execute "moonc . 2>> logs/updates.log"
                result and= 0 == os.execute "lapis migrate production >> logs/updates.log"
                result and= 0 == os.execute "lapis build production >> logs/updates.log"
                if result
                    return { json: { status: "successful", message: "server updated to latest version" } }
                else
                    return { json: { status: "failure", message: "check logs/updates.log"} }, status: 500 --Internal Server Error
            else
                return { json: { status: "successful", message: "ignored non-master push" } }
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

            --ok, result = pcall sandbox.run, @params.code, {quota: 2000, env: { :print, :lomeli }}
            @html ->
                p "Temporarily not allowing you guys to fuck up my server. Sorry. :P"
                --if ok
                --    pre style: "color:green;", result
                --else
                --    pre style: "color:red;", result
                --pre out
    }
