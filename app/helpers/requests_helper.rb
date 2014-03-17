module RequestsHelper

  def build_modal(request)
    str = "<button class=\"btn btn-primary btn-xs\" data-toggle=\"modal\" data-target=\"#myModal#{request.id}\"><span class=\"glyphicon glyphicon-list-alt\">  View Query</span></button>"

    str += "<div class=\"modal fade\" id=\"myModal#{request.id}\" tabindex=\"-1\" role=\"dialog\" aria-labelledby=\"myModalLabel\" aria-hidden=\"true\">"
    str +=   "<div class=\"modal-dialog\">"
    str +=     "<div class=\"modal-content\">"
    str +=       "<div class=\"modal-header\">"
    str +=         "<button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-hidden=\"true\">&times;</button>"
    str +=         "<h4 class=\"modal-title\" id=\"myModalLabel\">Query</h4>"
    str +=       "</div>"
    str +=       "<div class=\"modal-body\">#{request.query}</div>"
    str +=       "<div class=\"modal-footer\">"
    str +=         "<button type=\"button\" class=\"btn btn-default\" data-dismiss=\"modal\">Close</button>"
    str +=       "</div>"
    str +=     "</div>"
    str +=   "</div>"
    str += "</div>"

    return str.html_safe
  end

  def build_download_url(request)
    html = ""
    if request

        html += "<a href=\"http://localhost:3000/requests/#{request.id}/download\"><button class=\"btn btn-xs glyphicon glyphicon-download-alt\"><span class=\"badge pull-left\">#{request.results ? request.results : 0} Download</span></button></a></span></a>"

       # html += "<a class=\"glyphicon glyphicon-download-alt\" href=\"http://localhost:3000/requests/#{request.id}/download\"><span class=\"badge pull-right\">42 Items</span></a>"
      #html += link_to "Download - #{request.results ? request.results} results", download_request_path(request), :class => "glyphicon glyphicon-download-alt"
    else
        html += "<button class=\"btn btn-primary btn-xs\"><span class=\"glyphicon glyphicon-refresh\">Pending</span></button>"
    end
    return html.html_safe
  end
end
