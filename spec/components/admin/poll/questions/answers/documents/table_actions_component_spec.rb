require "rails_helper"

describe Admin::Poll::Questions::Answers::Documents::TableActionsComponent, controller: Admin::BaseController do
  before { sign_in(create(:administrator).user) }
  let(:future_answer) { create(:poll_question_answer, poll: create(:poll, :future)) }
  let(:current_answer) { create(:poll_question_answer, poll: create(:poll)) }

  it "displays the destroy action when the poll has not started" do
    document = create(:document, documentable: future_answer)

    render_inline Admin::Poll::Questions::Answers::Documents::TableActionsComponent.new(document)

    expect(page).to have_link "Download file"
    expect(page).to have_button "Delete"
    expect(page).not_to have_link "Edit"
  end

  it "does not display the destroy action when the poll has started" do
    document = create(:document, documentable: current_answer)

    render_inline Admin::Poll::Questions::Answers::Documents::TableActionsComponent.new(document)

    expect(page).to have_link "Download file"
    expect(page).not_to have_button "Delete"
    expect(page).not_to have_link "Edit"
  end
end
