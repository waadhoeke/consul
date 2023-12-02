require "rails_helper"

describe Admin::BudgetsWizard::Headings::GroupSwitcherComponent do
  it "renders a menu to switch group for budgets with two groups" do
    budget = create(:budget)
    group = create(:budget_group, budget: budget, name: "Parks")
    create(:budget_group, budget: budget, name: "Recreation")

    render_inline Admin::BudgetsWizard::Headings::GroupSwitcherComponent.new(group)

    expect(page).to have_content "Showing headings from the Parks group"
    expect(page).to have_button "Manage headings from a different group"

    page.find("button + ul") do |list|
      expect(list).to have_link "Recreation"
    end
  end
end
