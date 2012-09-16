class TopicsController < ApplicationController
  # GET /topics/new
  # GET /topics/new.json
  def new
    @channel = Channel.find(params[:id])
    @topic = @channel.topics.build(params[:topic])

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: [@chennel, @topic] }
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find(params[:id])
    @channel = Channel.find(@topic.channel_id)
  end

  # POST /topics
  # POST /topics.json
  def create
    channel = Channel.find(params[:channel_id])
    @topic = channel.topics.build(params[:topic])
    siblings= Topic.find_by_channel_id(params[:chennel_id])
    if siblings.nil?
      @topic.order = 0
    else
      @topic.order = siblings.size
    end

    respond_to do |format|
      if @topic.save
        format.html { redirect_to action: :edit, id: @topic.id, notice: 'Topic was successfully created.' }
        format.json { render json: @topic, status: :created, location: @topic }
      else
        format.html { redirect_to action: :new, id: channel.id }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.json
  def update
    @topic = Topic.find(params[:id])

    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        format.html { render action: "edit", notice: "Topic was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.json
  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy

    respond_to do |format|
      format.html { redirect_to channels_url }
      format.json { head :no_content }
    end
  end
end
