require File.expand_path('../../test_helper', __FILE__)

class RedmineEditauthorIssuesControllerTest < Redmine::ControllerTest
  tests IssuesController

  setup do
    User.current = nil
    # Add permission to Manager role (hence, to jsmith)
    manager_role = Role.find(1)
    manager_role.add_permission!(:edit_issue_author)
  end

  test "author field as authorized user in new" do
    session[:user_id] = 2
    get :new, params: { project_id: 1 }

    assert_select '#issue_author_id', false
  end

  test "author field in new with set original author permission" do
    Role.find(1).add_permission!(:set_original_issue_author)
    session[:user_id] = 2
    get :new, params: { project_id: 1 }

    assert_select '#issue_author_id'
  end

  test "author field as authorized user in edit" do
    session[:user_id] = 2
    get :edit, params: { id: 1 }

    assert_select '#issue_author_id' do
      assert_select 'option[value="3"]'
      # admin without membership in the project
      assert_select 'option[value="1"]'
      # member of other projects only
      assert_select 'option[value="8"]', false
      # locked member
      assert_select 'option[value="5"]', false
    end
  end

  test "author field as unauthorized user in edit" do
    session[:user_id] = 3
    get :edit, params: { id: 1 }

    assert_select '#issue_author_id', false
  end

  test "update author as authorized user" do
    session[:user_id] = 2

    assert_difference('Journal.count') do
      put :update, params: { id: 1, issue: { author_id: 3 } }
    end
    assert_redirected_to '/issues/1'
    assert_equal 3, Issue.find(1).author_id
  end

  test "update author to admin as authorized user" do
    session[:user_id] = 2

    put :update, params: { id: 1, issue: { author_id: 1 } }
    assert_redirected_to '/issues/1'
    assert_equal 1, Issue.find(1).author_id
  end

  test "update author as unauthorized user" do
    session[:user_id] = 3

    assert_no_difference('Journal.count') do
      put :update, params: { id: 1, issue: { author_id: 3 } }
    end
    assert_equal 2, Issue.find(1).author_id
  end

  test "update author to non member is rejected" do
    session[:user_id] = 2

    assert_no_difference('Journal.count') do
      put :update, params: { id: 1, issue: { author_id: 8 } }
    end
    assert_response :success
    assert_select '#errorExplanation'
    assert_equal 2, Issue.find(1).author_id
  end

  test "update author to locked member is rejected" do
    session[:user_id] = 2

    put :update, params: { id: 1, issue: { author_id: 5 } }
    assert_response :success
    assert_equal 2, Issue.find(1).author_id
  end

  test "update other attributes keeps author not in possible authors" do
    issue = Issue.find(1)
    issue.update_column(:author_id, 8)
    session[:user_id] = 2

    put :update, params: { id: 1, issue: { subject: 'Changed', author_id: 8 } }
    assert_redirected_to '/issues/1'
    issue.reload
    assert_equal 'Changed', issue.subject
    assert_equal 8, issue.author_id
  end

  test "create issue with original author" do
    Role.find(1).add_permission!(:set_original_issue_author)
    session[:user_id] = 2

    assert_difference('Issue.count') do
      post :create, params: {
        project_id: 1,
        issue: { tracker_id: 3, status_id: 2, priority_id: 5,
                 custom_field_values: { '2' => 'Value for field 2' },
                 subject: 'Original author', author_id: 3 }
      }
    end
    assert_equal 3, Issue.order(:id).last.author_id
  end

  test "create issue without permission keeps current user as author" do
    session[:user_id] = 2

    assert_difference('Issue.count') do
      post :create, params: {
        project_id: 1,
        issue: { tracker_id: 3, status_id: 2, priority_id: 5,
                 custom_field_values: { '2' => 'Value for field 2' },
                 subject: 'No original author', author_id: 3 }
      }
    end
    assert_equal 2, Issue.order(:id).last.author_id
  end
end
