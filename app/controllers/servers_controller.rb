class ServersController < ApplicationController
  before_action :set_server, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin, only: [:new, :create, :edit, :update, :destroy]
  # GET /servers
  # GET /servers.json
  def index
    @servers = Server.all
    puts @servers
  end

  # GET /servers/1
  # GET /servers/1.json
  def show
  end

  # GET /servers/new
  def new
    @server = Server.new
  end

  # GET /servers/1/edit
  def edit
  end

  # POST /servers
  # POST /servers.json
  def create
    # parse software fields from the post parameters into the server_params
    software = Array.new

    params.each do | key, value |

      key_matcher = /software\d+/
      if key_matcher.match?(key)
        software << value
      end
    end

    # merge server_params [and software information
    server_params[:installed_software] = software

    #server_params.permit(:name, :cpu_cores, :ram_mb, :storage_mb, :ipv4_address, :ipv6_address, :mac_address, :fqdn, :installed_software)
    server_params.permit!

    # create new Server object
    @server = Server.new(
      name: server_params[:name],
      cpu_cores: server_params[:cpu_cores],
      ram_mb: server_params[:ram_mb],
      storage_mb: server_params[:storage_mb],
      mac_address: server_params[:mac_address],
      fqdn: server_params[:fqdn],
      ipv4_address: server_params[:ipv4_address],
      ipv6_address: server_params[:ipv6_address],
      installed_software: server_params[:installed_software],
      )

    respond_to do |format|
      if @server.save
        format.html { redirect_to @server, notice: 'Server was successfully created.' }
        format.json { render :show, status: :created, location: @server }
      else
        format.html { render :new }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /servers/1
  # PATCH/PUT /servers/1.json
  def update
    respond_to do |format|
      if @server.update(server_params)
        format.html { redirect_to @server, notice: 'Server was successfully updated.' }
        format.json { render :show, status: :ok, location: @server }
      else
        format.html { render :edit }
        format.json { render json: @server.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /servers/1
  # DELETE /servers/1.json
  def destroy
    @server.destroy
    respond_to do |format|
      format.html { redirect_to servers_url, notice: 'Server was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_server
      @server = Server.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def server_params
      #params.require(:server).permit(:name, :cpu_cores, :ram_mb, :storage_mb, :ipv4_address, :ipv6_address,
      #                              :mac_address, :fqdn)

      params.fetch(:server, {})
    end

end
