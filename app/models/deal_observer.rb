class DealObserver < ActiveRecord::Observer
  def after_create(deal)
    Mailer.crm_deal_add(deal).deliver if Setting.notified_events.include?('crm_deal_added')
  end
  def after_update(deal)
    Mailer.crm_deal_updated(deal).deliver if deal.status_id_changed? && Setting.notified_events.include?('crm_deal_updated')
  end
end
