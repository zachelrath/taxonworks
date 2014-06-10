class CitationTopicsController < ApplicationController
  before_action :require_sign_in_and_project_selection
  before_action :set_citation_topic, only: [:show, :edit, :update, :destroy]

  # GET /citation_topics
  # GET /citation_topics.json
  def index
    @citation_topics = CitationTopic.all
  end

  # GET /citation_topics/1
  # GET /citation_topics/1.json
  def show
  end

  # GET /citation_topics/new
  def new
    @citation_topic = CitationTopic.new
  end

  # GET /citation_topics/1/edit
  def edit
  end

  # POST /citation_topics
  # POST /citation_topics.json
  def create
    @citation_topic = CitationTopic.new(citation_topic_params)

    respond_to do |format|
      if @citation_topic.save
        format.html { redirect_to @citation_topic, notice: 'Citation topic was successfully created.' }
        format.json { render :show, status: :created, location: @citation_topic }
      else
        format.html { render :new }
        format.json { render json: @citation_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /citation_topics/1
  # PATCH/PUT /citation_topics/1.json
  def update
    respond_to do |format|
      if @citation_topic.update(citation_topic_params)
        format.html { redirect_to @citation_topic, notice: 'Citation topic was successfully updated.' }
        format.json { render :show, status: :ok, location: @citation_topic }
      else
        format.html { render :edit }
        format.json { render json: @citation_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /citation_topics/1
  # DELETE /citation_topics/1.json
  def destroy
    @citation_topic.destroy
    respond_to do |format|
      format.html { redirect_to citation_topics_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_citation_topic
      @citation_topic = CitationTopic.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def citation_topic_params
      params.require(:citation_topic).permit(:citation_id, :topic_id)
    end
end
