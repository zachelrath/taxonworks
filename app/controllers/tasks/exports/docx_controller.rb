class Tasks::Exports::DocxController < ApplicationController
    include TaskControllerConfiguration
  
    def index
    end
  
    def download
      redirect_to export_docx_task_path, notice: 'Nothing selected' and return unless !params[:otu_id].blank?
      @otu = Otu.where(project_id: sessions_current_project_id).find(params.require(:otu_id))
      if @otu.taxon_name
        if Rails.env == 'development'
          download = ::Export::Docx.download(@otu, request.url)
        # else
        #   download = ::Export::Docx.download_async(@otu, request.url)
        end
        redirect_to file_download_path(download)
      else
        redirect_to export_docx_task_path, notice: 'Please select an OTU that is linked to the nomenclature (has a taxon name).'
      end
    end
  
  end
  