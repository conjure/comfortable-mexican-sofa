class Comfy::Admin::Cms::SitesController < Comfy::Admin::Cms::BaseController

  skip_before_action  :load_admin_site,
                      :load_fixtures

  before_action :build_site,  :only => [:new, :create]
  before_action :load_site,   :only => [:edit, :update, :destroy]

  def index
    p ">>>>>>>>>>>>>>>>>>>>>>>>>>> Comfy access"
    return redirect_to '/users/sign_in'  if current_user.nil?
    return redirect_to :action => :new if ::Comfy::Cms::Site.count == 0
    @site = ::Comfy::Cms::Site.find_by_id(session[:site_id])
    @site = nil unless @site.nil? || (current_user.has_role?(@site.identifier.to_sym) || current_user.has_role?(:sysadmin))
    @sites ||= ::Comfy::Cms::Site.all.reject { |s| current_user.nil? || (!current_user.has_role?(s.identifier.to_sym) && !current_user.has_role?(:sysadmin)) }
    
  end

  def new
    render
  end

  def edit
    render
  end

  def create
    @site.save!
    flash[:success] = I18n.t('comfy.admin.cms.sites.created')
    redirect_to comfy_admin_cms_site_layouts_path(@site)
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = I18n.t('comfy.admin.cms.sites.creation_failure')
    render :action => :new
  end

  def update
    @site.update_attributes!(site_params)
    flash[:success] = I18n.t('comfy.admin.cms.sites.updated')
    redirect_to :action => :edit, :id => @site
  rescue ActiveRecord::RecordInvalid
    flash.now[:error] = I18n.t('comfy.admin.cms.sites.update_failure')
    render :action => :edit
  end

  def destroy
    @site.destroy
    flash[:success] = I18n.t('comfy.admin.cms.sites.deleted')
    redirect_to :action => :index
  end

protected

  def build_site
    @site = ::Comfy::Cms::Site.new(site_params)
    @site.hostname ||= request.host.downcase
  end

  def load_site
    @site = ::Comfy::Cms::Site.find(params[:id])
    @site = nil unless @site.nil? || (current_user.has_role?(@site.identifier.to_sym) || current_user.has_role?(:sysadmin))
    raise ActiveRecord::RecordNotFound if @site.nil?
    I18n.locale = ComfortableMexicanSofa.config.admin_locale || @site.locale
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('comfy.admin.cms.sites.not_found')
    redirect_to :action => :index
  end
  
  def site_params
    params.fetch(:site, {}).permit!
  end

end
