lapis = require "lapis"

import respond_to, json_params from require "lapis.application"

Users = require "models.Users"

class extends lapis.Application
	[githook: "/githook"]: respond_to {
        GET: =>
            return status: 404
        POST: json_params =>
            if @params.ref == "refs/heads/master"
                os.execute "echo \"Updating server...\" >> logs/updates.log"
                os.execute "git pull origin >> logs/updates.log"
                os.execute "moonc . >> logs/updates.log" -- NOTE this doesn't actually work, figure out correct stream to output to file
                os.execute "lapis migrate production >> logs/updates.log"
                os.execute "lapis build production >> logs/updates.log"
                return { json: { status: "successful" } } -- yes, I know this doesn't actually check if it was successful yet
            else
                return { json: { status: "ignored non-master push" } }
    }

    [index: "/"]: =>
    	@html ->
    		ul ->
	    		if @session.id
	    			li ->
	    				a href: @url_for "logout", "Log out!"
	    		else
		    		li ->
    		    		a href: @url_for "create_user", "Make an account."
    				li ->
    					a href: @url_for "login", "Log in!"

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
    				input type: "text", name: "password"
    				br!
    				input type: "submit"
    	POST: =>
    		if @params.user and @params.password
    			user = Users\create {
    				name: @params.user
    				password: @params.password
    			}
    			if user
    				@session.id = user.id
    			else
    				return "Error." --this code should be unreachable
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
    				input type: "text", name: "password"
    				br!
    				input type: "submit"
    	POST: =>
    		if @params.user and @params.password
    			if user = Users\find name: @params.name
    				if user.password == @params.password
    					@session.id = user.id
    					return redirect_to: @url_for "index"
    }

    [logout: "/logout"]: =>
    	@session.id = nil
    	return redirect_to: @url_for "index"
