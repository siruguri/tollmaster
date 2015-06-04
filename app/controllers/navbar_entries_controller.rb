class NavbarEntriesController < ApplicationController
  before_action :set_navbar_entry, only: [:show, :edit, :update, :destroy]

  # GET /navbar_entries
  # GET /navbar_entries.json
  def index
    @navbar_entries = NavbarEntry.all
  end

  # GET /navbar_entries/1
  # GET /navbar_entries/1.json
  def show
  end

  # GET /navbar_entries/new
  def new
    @navbar_entry = NavbarEntry.new
  end

  # GET /navbar_entries/1/edit
  def edit
  end

  # POST /navbar_entries
  # POST /navbar_entries.json
  def create
    @navbar_entry = NavbarEntry.new(navbar_entry_params)

    respond_to do |format|
      if @navbar_entry.save
        format.html { redirect_to @navbar_entry, notice: 'Navbar entry was successfully created.' }
        format.json { render action: 'show', status: :created, location: @navbar_entry }
      else
        format.html { render action: 'new' }
        format.json { render json: @navbar_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /navbar_entries/1
  # PATCH/PUT /navbar_entries/1.json
  def update
    respond_to do |format|
      if @navbar_entry.update(navbar_entry_params)
        format.html { redirect_to @navbar_entry, notice: 'Navbar entry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @navbar_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /navbar_entries/1
  # DELETE /navbar_entries/1.json
  def destroy
    @navbar_entry.destroy
    respond_to do |format|
      format.html { redirect_to navbar_entries_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_navbar_entry
      @navbar_entry = NavbarEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def navbar_entry_params
      params.require(:navbar_entry).permit(:title, :url)
    end
end
