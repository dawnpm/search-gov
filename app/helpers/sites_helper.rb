module SitesHelper
  def site_select
    sites = current_user.affiliates.map { |p| ["#{p.display_name} (#{p.name})", p.id] }
    select_options = {include_blank: true, selected: nil}
    html_options = {id: 'site_select', class: 'site-select'}
    select 'site', 'id', sites, select_options, html_options
  end

  def daily_snapshot_toggle(membership)
    return if membership.nil?
    description_class = 'description label off-screen-text'
    if membership.gets_daily_snapshot_email?
      button_class = 'btn disabled'
      description_class << ' label-warning'
      verb = 'Stop sending'
    else
      button_class = 'btn'
      verb = 'Send'
    end
    title = "#{verb} me today's snapshot as a daily email"
    wrapper_options = {id: 'envelope-snapshot-toggle',
                       'data-toggle' => 'tooltip',
                       'data-original-title' => title}

    form_for membership, as: :membership, url: site_membership_path(@site, membership), method: :put, html: wrapper_options do
      button_tag class: button_class, type: :submit do
        inner_html = stacked_envelope
        inner_html << content_tag(:span, title, class: description_class)
        if membership.gets_daily_snapshot_email?
          content_tag :div, inner_html, class: 'btn disabled'
        else
          inner_html
        end
      end
    end
  end

  def site_pin(site)
    if current_user.default_affiliate_id != site.id
      button_to_enabled_pin_site(site)
    else
      button_to_disabled_pin_site
    end
  end

  def button_to_enabled_pin_site(site)
    title = 'Set as my default site'
    wrapper_options = {id: 'pin-site',
                       'data-toggle' => 'tooltip',
                       'data-original-title' => title}

    form_for site, as: :site, url: pin_site_path(site), html: wrapper_options do
      button_tag class: 'btn', type: :submit do
        inner_html = stacked_pushpin
        inner_html << content_tag(:span, title, class: 'description label off-screen-text')
      end
    end
  end

  def button_to_disabled_pin_site
    title = 'Your default site'
    wrapper_options = {id: 'pin-site',
                       'data-toggle' => 'tooltip',
                       'data-original-title' => title}
    content_tag :div, wrapper_options do
      inner_html = stacked_pushpin
      inner_html << content_tag(:span, title, class: 'description label label-warning off-screen-text')
      content_tag :div, inner_html, class: 'btn disabled'
    end
  end

  def content_for_site_page_title(site, title)
    content_for :title, "#{title} - #{site.display_name}"
  end

  def main_nav_item(title, path, icon, nav_controllers, link_options = {})
    link_options.reverse_merge! 'data-toggle' => 'tooltip', 'data-original-title' => title
    item_content = link_to path, link_options do
      inner_html = content_tag :i, nil, class: "#{icon} icon-2x"
      inner_html << content_tag(:span, title, class: 'description')
    end
    content_tag :li, item_content, main_nav_css_class_hash(nav_controllers)
  end

  def main_nav_css_class_hash(nav_controllers)
    nav_controllers.include?(controller_name) ? {class: 'active'} : {}
  end

  def preview_main_nav_item(site, title)
    if site.force_mobile_format?
      main_nav_item title, search_url(protocol: 'http', affiliate: site.name, query: 'gov'), 'icon-eye-open', [], target: '_blank'
    else
      main_nav_item title, site_preview_path(site), 'icon-eye-open', [], preview_serp_link_options
    end
  end

  def site_dashboard_controllers
    %w(settings sites users)
  end

  def site_activate_search_controllers
    %w(embed_codes api_instructions)
  end

  def site_analytics_controllers
    %w(queries clicks monthly_reports raw_logs_accesses third_party_tracking_requests click_queries query_clicks)
  end

  def site_manage_content_controllers
    %w(boosted_contents boosted_contents_bulk_uploads
       contents document_collections domains excluded_urls
       flickr_profiles indexed_documents rss_feeds site_feed_urls
       twitter_profiles youtube_profiles featured_collections)
  end

  def site_manage_display_controllers
    %w(header_and_footers displays font_and_colors image_assets)
  end

  def list_item_with_link_to_current_help_page
    help_link = HelpLink.lookup(request, controller.action_name)
    content_tag(:li, link_to('Help?', help_link.help_page_url, class: 'help-link menu')) if help_link
  end

  def site_nav_css_class_hash(*nav_names)
    nav_names.include?(controller_name) ? {class: 'active'} : {}
  end

  def site_locale(site)
    site.locale == 'es' ? 'Spanish' : 'English'
  end

  def list_item_with_link_to_preview_serp(title, site, options = {})
    return if options[:staged].present? and !site.has_staged_content?

    content_tag :li do
      link_options = { affiliate: site.name, protocol: 'http', query: 'gov' }.merge options
      link_to title, search_url(link_options), target: '_blank'
    end
  end

  def link_to_add_new_boosted_content_keyword(title, site, boosted_content)
    instrumented_link_to title, new_keyword_site_best_bets_texts_path(site), boosted_content.boosted_content_keywords.length, 'keyword'
  end

  def link_to_add_new_featured_collection_keyword(title, site, featured_collection)
    instrumented_link_to title, new_keyword_site_best_bets_graphics_path(site), featured_collection.featured_collection_keywords.length, 'keyword'
  end

  def preview_serp_link_options
    { class: 'modal-page-viewer-link',
      'data-modal-container' => '#preview-container',
      'data-modal-content-selector' => '#preview',
      'data-modal-title' => content_tag(:h1, 'Preview Search Results') }
  end
end
