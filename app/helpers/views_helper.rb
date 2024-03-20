 module ViewsHelper 

  ### provide full title of a page
  def full_title(page_title)
    base_title = $AppName
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  ### provide breadcrumbs for show or edit Views
  def breadcrumbs(child_object)
    way_back = [child_object]
    if child_object.class != Playground # do not consider the parents of a playground
      begin
        path = child_object.parent
        way_back << path
        child_object = path
      end until (child_object.class == Playground or child_object.nil?) # stop when comes to display the Playground
    end
    puts way_back.reverse
    way_back.reverse
  end

end
