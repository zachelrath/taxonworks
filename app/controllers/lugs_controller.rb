class LugsController < ApplicationController
  before_action :set_lug, only: [:show, :edit, :update, :destroy]

  # GET /lugs
  # GET /lugs.json
  def index
    @lugs = Lug.all
  end

  # GET /lugs/1
  # GET /lugs/1.json
  def show
  end

  # GET /lugs/new
  def new
    @lug = Lug.new
  end

  # GET /lugs/1/edit
  def edit
  end

  # POST /lugs
  # POST /lugs.json
  def create
    @lug = Lug.new(lug_params)

    respond_to do |format|
      if @lug.save
        format.html { redirect_to @lug, notice: 'Lug was successfully created.' }
        format.json { render :show, status: :created, location: @lug }
      else
        format.html { render :new }
        format.json { render json: @lug.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lugs/1
  # PATCH/PUT /lugs/1.json
  def update
    respond_to do |format|
      if @lug.update(lug_params)
        format.html { redirect_to @lug, notice: 'Lug was successfully updated.' }
        format.json { render :show, status: :ok, location: @lug }
      else
        format.html { render :edit }
        format.json { render json: @lug.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lugs/1
  # DELETE /lugs/1.json
  def destroy
    @lug.destroy
    respond_to do |format|
      format.html { redirect_to lugs_url, notice: 'Lug was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lug
      @lug = Lug.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lug_params
      params.fetch(:lug, {})
    end
end
