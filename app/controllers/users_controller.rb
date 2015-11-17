class UsersController < ApplicationController
    before_filter :skip_first_page, :only => :new

    def new
        @bodyId = 'home'
        @is_mobile = mobile_device?

        @user = User.new

        @ref_code = params[:refer_code]
       
        respond_to do |format|
            format.html # new.html.erb
        end

    end

    def create
        # Get user to see if they have already signed up
        @user = User.find_by_email(params[:user][:email]);
            
        # If user doesnt exist, make them, and attach referrer
        if @user.nil?

            cur_ip = IpAddress.find_by_address(request.env['HTTP_X_FORWARDED_FOR'])

            if !cur_ip
                cur_ip = IpAddress.create(
                    :address => request.env['HTTP_X_FORWARDED_FOR'],
                    :count => 0
                )
            end

            if cur_ip.count > 2
                return redirect_to root_path
            else
                cur_ip.count = cur_ip.count + 1
                cur_ip.save
            end

            @user = User.new(:email => params[:user][:email])
          puts params[:user]
            @referred_by = User.find_by_referral_code(cookies[:h_ref])

            
            @user.save
            if params[:user][:referral_code] && params[:user][:referral_code] != ''
                @find_user = User.where(:referral_code => params[:user][:referral_code]).first
                @refer_count = Refers.where(:refer_by => @find_user.id)
                @total_refer = @refer_count.length
                @total_refer = @total_refer+1

                if @total_refer  >= 5 && @total_refer < 10
                    @price = 10
                elsif @total_refer  >= 10 && @total_refer  < 25
                    @price = 20
                 elsif @total_refer  >= 25 && @total_refer  < 50
                    @price = 50
                elsif @total_refer  >= 50 && @total_refer  < 100
                    @price = 100
                elsif @total_refer  >= 100
                    @price = 1000
                else
                    @price = 0
                end

                @pcode = SecureRandom.hex(5)
                @ucount = Promocodes.where(:userid => @find_user.id)
                @mcount = @ucount.length

                puts @mcount
               if @mcount > 0

                Promocodes.where('userid': @find_user.id).update_all(invited_users: @total_refer, promo_code: @pcode , code_price: @price)

               else
                 @promo = Promocodes.new(:userid => @find_user.id, :invited_users => @total_refer, :promo_code => @pcode, :code_price => @price)
                @promo.save
               end
               
               
                @refer = Refers.new(:refer_by => @find_user.id, :userid => @user.id)
                @refer.save
            end
        end

        # Send them over refer action
        respond_to do |format|
            if !@user.nil?
                cookies[:h_email] = { :value => @user.email }
                format.html { redirect_to '/refer-a-friend' }
            else
                format.html { redirect_to root_path, :alert => "Something went wrong!" }
            end
        end
    end

    def refer
        email = cookies[:h_email]

        @bodyId = 'refer'
        @is_mobile = mobile_device?

        @user = User.find_by_email(email)

        @refer_count = Refers.where(:refer_by => @user.id)
        @total_refer = @refer_count.length
        #puts @total_refer
        respond_to do |format|
            if !@user.nil?
                format.html #refer.html.erb
            else
                format.html { redirect_to root_path, :alert => "Something went wrong!" , :total_reffred_users => @total_refer  }
            end
        end
    end

    def policy
          
    end  

    def redirect
        redirect_to root_path, :status => 404
    end

    private 

    def skip_first_page
        if !Rails.application.config.ended
            email = cookies[:h_email]
            if email and !User.find_by_email(email).nil?
                redirect_to '/refer-a-friend'
            else
                cookies.delete :h_email
            end
        end
    end

end
