# -*- encoding: utf-8 -*-
class ContentsController < ApplicationController
  before_action :set_content, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session, only: [:call]

  # アプリの起動ページ
  def start
    # ユーザーを再生成
    generate_user!
  end

  # 電話が終わるまで待つ
  def wait
    if current_user.finish_question?
      redirect_to :finish
    end
  end

  # 電話が終わるまで待つ
  def check
    render json: {finish: current_user.finish_question?}
  end

  # 電話をかけるアクション(Ajaxからkickされる)
  def call
    # 電話番号を国際電話
    tel = params[:tel].sub(/^0/, '+81').gsub(/\-/, '')
    date = params[:date] && params[:date].gsub(/\-/, '') # 2014-02-15形式で来る

    current_user.update_attributes({
      tel: tel,
      number: params[:number],
      date: date,
      span: params[:span]
    })

    client = Twilio::REST::Client.new Settings.twilio.account_sid, Settings.twilio.auth_token

    client.account.calls.create(
      :from => Settings.twilio.caller_id, # 発信者
      :to => tel,   # 電話先
      :url => "#{Settings.app_host}/twiml/start?user_id=#{current_user.id}" # twxml
    )

    render json: {status: 'ok'}
  end


  # 検索終了
  def finish
    @user = current_user
  end

  # # GET /contents
  # # GET /contents.json
  # def index
  #   @content = Content.new
  # end

  # # GET /contents/1
  # # GET /contents/1.json
  # def show
  # end

  # # GET /contents/new
  # def new
  #   @content = Content.new
  # end

  # # GET /contents/1/edit
  # def edit
  # end




  # # POST /contents
  # # POST /contents.json
  # def create
  #   @content = Content.new(content_params)

  #   respond_to do |format|
  #     if @content.save
  #       format.html { redirect_to @content, notice: 'Content was successfully created.' }
  #       format.json { render action: 'show', status: :created, location: @content }
  #     else
  #       format.html { render action: 'new' }
  #       format.json { render json: @content.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /contents/1
  # # PATCH/PUT /contents/1.json
  # def update
  #   respond_to do |format|
  #     if @content.update(content_params)
  #       format.html { redirect_to @content, notice: 'Content was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @content.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /contents/1
  # # DELETE /contents/1.json
  # def destroy
  #   @content.destroy
  #   respond_to do |format|
  #     format.html { redirect_to contents_url }
  #     format.json { head :no_content }
  #   end
  # end

  # private
  #   # Use callbacks to share common setup or constraints between actions.
  #   def set_content
  #     @content = Content.find(params[:id])
  #   end

  #   # Never trust parameters from the scary internet, only allow the white list through.
  #   def content_params
  #     params.require(:content).permit(:image_url, :url, :title)
  #   end
end
