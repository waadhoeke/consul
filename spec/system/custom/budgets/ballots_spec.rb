require "rails_helper"
require "sessions_helper"

describe "Ballots" do
  let(:user)        { create(:user, :level_two) }
  let!(:budget)     { create(:budget, :balloting) }
  let!(:states)     { create(:budget_group, budget: budget, name: "States") }
  let!(:new_york)   { create(:budget_heading, group: states, name: "New York", price: 1000000) }

  context "Voting" do
    before { login_as(user) }

    let!(:city) { create(:budget_group, budget: budget, name: "City") }
    let!(:districts) { create(:budget_group, budget: budget, name: "Districts") }

    context "Group and Heading Navigation" do
      scenario "Groups and Headings" do
        create(:budget_heading, group: city,      name: "Investments Type1")
        create(:budget_heading, group: city,      name: "Investments Type2")
        create(:budget_heading, group: districts, name: "District 1")
        create(:budget_heading, group: districts, name: "District 2")

        visit budget_path(budget)

        within("#groups_and_headings") do
          expect(page).to have_content "City"
          expect(page).to have_content "Investments Type1"
          expect(page).to have_content "Investments Type2"

          expect(page).to have_content "Districts"
          expect(page).to have_link "District 1 €1,000,000"
          expect(page).to have_link "District 2 €1,000,000"
        end
      end

      scenario "Investments" do
        create(:budget_heading, group: city, name: "Under the city")

        create(:budget_heading, group: city, name: "Above the city") do |heading|
          create(:budget_investment, :selected, heading: heading, title: "Solar panels")
          create(:budget_investment, :selected, heading: heading, title: "Observatory")
        end

        create(:budget_heading, group: districts, name: "District 1") do |heading|
          create(:budget_investment, :selected, heading: heading, title: "New park")
          create(:budget_investment, :selected, heading: heading, title: "Zero-emission zone")
        end

        create(:budget_heading, group: districts, name: "District 2") do |heading|
          create(:budget_investment, :selected, heading: heading, title: "Climbing wall")
        end

        visit budget_path(budget)
        click_link "Above the city €1,000,000"

        expect(page).to have_css(".budget-investment", count: 2)
        expect(page).to have_content "Solar panels"
        expect(page).to have_content "Observatory"

        visit budget_path(budget)
        click_link "District 1 €1,000,000"

        expect(page).to have_css(".budget-investment", count: 2)
        expect(page).to have_content "New park"
        expect(page).to have_content "Zero-emission zone"

        visit budget_path(budget)
        click_link "District 2 €1,000,000"

        expect(page).to have_css(".budget-investment", count: 1)
        expect(page).to have_content "Climbing wall"
      end
    end

    context "Adding and Removing Investments" do
      scenario "Add a investment" do
        create(:budget_investment, :selected, heading: new_york, price: 10000, title: "Bring back King Kong")
        create(:budget_investment, :selected, heading: new_york, price: 20000, title: "Paint cabs black")

        visit budget_investments_path(budget, heading_id: new_york)
        add_to_ballot("Bring back King Kong")

        expect(page).to have_css("#amount_spent", text: "€10,000")
        expect(page).to have_css("#amount_available", text: "€990,000")

        within("#sidebar") do
          expect(page).to have_content "Bring back King Kong"
          expect(page).to have_content "€10,000"
          expect(page).to have_link "Submit my ballot"
        end

        add_to_ballot("Paint cabs black")

        expect(page).to have_css("#amount_spent", text: "€30,000")
        expect(page).to have_css("#amount_available", text: "€970,000")

        within("#sidebar") do
          expect(page).to have_content "Paint cabs black"
          expect(page).to have_content "€20,000"
          expect(page).to have_link "Submit my ballot"
        end
      end

      scenario "Removing a investment" do
        investment = create(:budget_investment, :selected, heading: new_york, price: 10000, balloters: [user])

        visit budget_investments_path(budget, heading_id: new_york)

        expect(page).to have_content investment.title
        expect(page).to have_css("#amount_spent", text: "€10,000")
        expect(page).to have_css("#amount_available", text: "€990,000")

        within("#sidebar") do
          expect(page).to have_content investment.title
          expect(page).to have_content "€10,000"
          expect(page).to have_link "Submit my ballot"
        end

        within("#budget_investment_#{investment.id}") do
          click_button "Remove vote"
        end

        expect(page).to have_css("#amount_spent", text: "€0")
        expect(page).to have_css("#amount_available", text: "€1,000,000")

        within("#sidebar") do
          expect(page).not_to have_content investment.title
          expect(page).not_to have_content "€10,000"
          expect(page).to have_link "Submit my ballot"
        end
      end
    end

    context "Balloting in multiple headings" do
      scenario "Independent progress bar for headings" do
        city_heading      = create(:budget_heading, group: city,      name: "All city",   price: 10000000)
        district_heading1 = create(:budget_heading, group: districts, name: "District 1", price: 1000000)
        district_heading2 = create(:budget_heading, group: districts, name: "District 2", price: 2000000)

        create(:budget_investment, :selected, heading: city_heading,      price: 10000, title: "Cheap")
        create(:budget_investment, :selected, heading: district_heading1, price: 20000, title: "Average")
        create(:budget_investment, :selected, heading: district_heading2, price: 30000, title: "Expensive")

        visit budget_investments_path(budget, heading_id: city_heading)

        add_to_ballot("Cheap")

        expect(page).to have_css("#amount_spent", text: "€10,000")
        expect(page).to have_css("#amount_available", text: "€9,990,000")

        within("#sidebar") do
          expect(page).to have_content "Cheap"
          expect(page).to have_content "€10,000"
        end

        visit budget_investments_path(budget, heading_id: district_heading1)

        expect(page).to have_css("#amount_spent", text: "€0")
        expect(page).to have_css("#amount_available", text: "€1,000,000")

        add_to_ballot("Average")

        expect(page).to have_css("#amount_spent",     text: "€20,000")
        expect(page).to have_css("#amount_available", text: "€980,000")

        within("#sidebar") do
          expect(page).to have_content "Average"
          expect(page).to have_content "€20,000"

          expect(page).not_to have_content "Cheap"
          expect(page).not_to have_content "€10,000"
        end

        visit budget_investments_path(budget, heading_id: city_heading)

        expect(page).to have_css("#amount_spent",     text: "€10,000")
        expect(page).to have_css("#amount_available", text: "€9,990,000")

        within("#sidebar") do
          expect(page).to have_content "Cheap"
          expect(page).to have_content "€10,000"

          expect(page).not_to have_content "Average"
          expect(page).not_to have_content "€20,000"
        end

        visit budget_investments_path(budget, heading_id: district_heading2)

        expect(page).to have_content("You have active votes in another heading: District 1")
      end
    end

    scenario "Display progress bar after first vote" do
      create(:budget_investment, :selected, heading: new_york, price: 10000, title: "Park expansion")

      visit budget_investments_path(budget, heading_id: new_york.id)

      add_to_ballot("Park expansion")

      within("#progress_bar") do
        expect(page).to have_css("#amount_spent", text: "€10,000")
      end
    end
  end

  scenario "Removing investments from ballot (sidebar)" do
    investment1 = create(:budget_investment, :selected, price: 10000, heading: new_york)
    investment2 = create(:budget_investment, :selected, price: 20000, heading: new_york)
    user = create(:user, :level_two, ballot_lines: [investment1, investment2])

    login_as(user)
    visit budget_investments_path(budget, heading_id: new_york.id)

    expect(page).to have_css("#amount_spent", text: "€30,000")
    expect(page).to have_css("#amount_available", text: "€970,000")

    within("#sidebar") do
      expect(page).to have_content investment1.title
      expect(page).to have_content "€10,000"

      expect(page).to have_content investment2.title
      expect(page).to have_content "€20,000"
    end

    within("#sidebar #budget_investment_#{investment1.id}_sidebar") do
      click_link "Remove vote"
    end

    expect(page).to have_css("#amount_spent", text: "€20,000")
    expect(page).to have_css("#amount_available", text: "€980,000")

    within("#sidebar") do
      expect(page).not_to have_content investment1.title
      expect(page).not_to have_content "€10,000"

      expect(page).to have_content investment2.title
      expect(page).to have_content "€20,000"
    end
  end
end
