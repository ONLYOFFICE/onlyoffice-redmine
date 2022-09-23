require_dependency "attachment"
require_dependency "user"

class OnlyofficeBaseController < AccountController

    protected

    def find_attachment
        @attachment = Attachment.find(params[:id])
        # Show 404 if the filename in the url is wrong
        raise ActiveRecord::RecordNotFound if params[:filename] && params[:filename] != @attachment.filename
    
        @project = @attachment.project
      rescue ActiveRecord::RecordNotFound
        render_404
      end
    
      # Checks that the file exists and is readable
      def file_readable
        if @attachment.readable?
          true
        else
          logger.error "Cannot send attachment, #{@attachment.diskfile} does not exist or is unreadable."
          render_404
        end
      end
    
      def read_authorize(user=User.current)
        @attachment.visible?(user) ? true : deny_access
      end
end