class EmployeesController < ApplicationController
  before_action :set_file, only: :import

  def dashboard
    india_and_uae_states = Employee::STATES
    india_and_uae_employees = Employee.where(state: india_and_uae_states)

    india_employees = india_and_uae_employees.filter_by_state('India')
    uae_employees = india_and_uae_employees.filter_by_state('UAE')

    @employee_chart_data = generate_employee_chart_data(india_employees, uae_employees)

  end

  def import
    success, response_message = read_employee_counts_from_xlsx_file
    if success
      flash[:notice] = response_message
    else
      flash[:error] = response_message
    end
    redirect_to root_path
  end

  def export
    @employees = Employee.all

    respond_to do |format|
      format.html
      format.json { render json: @employees }
      format.csv { send_data @employees.to_csv, filename: "employees-#{Date.today}.csv" }
    end
  end

  private

  def read_employee_counts_from_xlsx_file
    xlsx = Roo::Excelx.new(@file.path)

    employee_attrs = []
    errors = []

    # Keep track of states that have already been seen to detect duplicates
    states_seen = Set.new

    xlsx.each_row_streaming(offset: 2) do |row|
      state, permanent, contract, permanent_male, permanent_female, contract_male, contract_female = row.map(&:value)
      next if state.blank?

      # Check for duplicates
      if states_seen.include?(state)
        errors << "Duplicate data detected for state '#{state}'. Skipping this row."
        next
      else
        states_seen.add(state)
      end

      overall_workforce = permanent.to_i + contract.to_i
      total_male_employees = permanent_male.to_i + contract_male.to_i
      total_female_employees = permanent_female.to_i + contract_female.to_i

      if overall_workforce.zero? || total_male_employees.zero? || total_female_employees.zero?
        errors << "Invalid data detected for state '#{state}'. Skipping this row."
        next
      end

      male_female_ratio = (total_male_employees.to_f / total_female_employees).round(2)
      employee_attrs << {
        state:,
        permanent: permanent.to_i,
        contract: contract.to_i,
        permanent_male: permanent_male.to_i,
        permanent_female: permanent_female.to_i,
        contract_male: contract_male.to_i,
        contract_female: contract_female.to_i,
        overall_workforce:,
        male_female_ratio: "#{male_female_ratio}:1"
      }
    end

    Employee.upsert_all(employee_attrs, unique_by: :state)
    if errors.empty?
      [true, 'Employees successfully imported.']
    else
      [false, errors]
    end
  end

  def generate_employee_chart_data(india_employees, uae_employees)
    (Employee.column_names - ["id", "state", "created_at", "updated_at"]).map do |column|
      {
        name: column.titleize,
        data: {
          'India': india_employees.try(column.to_sym) || 0,
          'UAE': uae_employees.try(column.to_sym) || 0
        }
      }
    end
  end

  def set_file
    @file = params[:excel_file]
  end

end
