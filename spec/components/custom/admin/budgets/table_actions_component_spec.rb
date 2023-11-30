require "rails_helper"

describe Admin::Budgets::TableActionsComponent, controller: Admin::BaseController do
  let(:budget) { create(:budget) }
  let(:component) { Admin::Budgets::TableActionsComponent.new(budget) }

  it "renders links to edit budget, manage investments and preview budget" do
    render_inline component

    expect(page).to have_link count: 3
    expect(page).to have_link "Investment projects", href: /investments/
    expect(page).to have_link "Edit", href: /#{budget.id}\Z/
    expect(page).to have_link "Preview", href: /budgets/

    expect(page).not_to have_button
  end
end
