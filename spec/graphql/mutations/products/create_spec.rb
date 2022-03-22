# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Products::Create, type: :graphql do
  let(:membership) { create(:membership) }
  let(:organization) { membership.organization }
  let(:mutation) do
    <<~GQL
      mutation($input: CreateProductInput!) {
        createProduct(input: $input) {
          id,
          name,
          billableMetrics { id, name }
        }
      }
    GQL
  end

  let(:billable_metrics) do
    create_list(:billable_metric, 3, organization: organization)
  end

  it 'creates a product' do
    result = execute_graphql(
      current_user: membership.user,
      query: mutation,
      variables: {
        input: {
          name: 'New Product',
          organizationId: organization.id,
          billableMetricIds: billable_metrics.map(&:id)
        }
      }
    )

    result_data = result['data']['createProduct']

    aggregate_failures do
      expect(result_data['id']).to be_present
      expect(result_data['name']).to eq('New Product')
      expect(result_data['billableMetrics'].count).to eq(3)
    end
  end

  context 'without current user' do
    it 'returns an error' do
      result = execute_graphql(
        query: mutation,
        variables: {
          input: {
            name: 'New Product',
            organizationId: organization.id,
            billableMetricIds: billable_metrics.map(&:id)
          }
        }
      )

      expect_unauthorized_error(result)
    end
  end
end