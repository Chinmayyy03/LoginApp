<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bank Account Creation</title>
  <link rel="stylesheet" href="css/addCustomer.css">
</head>
<body>

  <div class="container">
    <h2>Bank Account Creation Form</h2>

    <!-- Moved buttons INSIDE the form -->
    <form id="accountForm" action="CreateAccountServlet" method="post" class="form-grid" onsubmit="return validateForm();">

      <!-- Personal Information -->
      <fieldset>
        <legend>Personal Information</legend>
        <div class="row">
          <label>First Name:</label>
          <input type="text" name="firstName" required>
        </div>
        <div class="row">
          <label>Middle Name:</label>
          <input type="text" name="middleName">
        </div>
        <div class="row">
          <label>Last Name:</label>
          <input type="text" name="lastName" required>
        </div>
        <div class="row">
          <label>Date of Birth:</label>
          <input type="date" name="dob" required>
        </div>
        <div class="row">
          <label>Gender:</label>
          <select name="gender" required>
            <option value="">Select</option>
            <option>Male</option>
            <option>Female</option>
            <option>Other</option>
          </select>
        </div>
      </fieldset>

      <!-- Contact Information -->
      <fieldset>
        <legend>Contact Information</legend>
        <div class="row">
          <label>Email ID:</label>
          <input type="email" name="email" required>
        </div>
        <div class="row">
          <label>Mobile Number:</label>
          <input type="text" name="mobile" maxlength="10" required>
        </div>
        <div class="row">
          <label>Alternate Number:</label>
          <input type="text" name="alternateMobile" maxlength="10">
        </div>
      </fieldset>

      <!-- Address Information -->
      <fieldset>
        <legend>Address Information</legend>
        <div class="row">
          <label>Address Line 1:</label>
          <input type="text" name="address1" required>
        </div>
        <div class="row">
          <label>Address Line 2:</label>
          <input type="text" name="address2">
        </div>
        <div class="row">
          <label>City:</label>
          <input type="text" name="city" required>
        </div>
        <div class="row">
          <label>State:</label>
          <input type="text" name="state" required>
        </div>
        <div class="row">
          <label>Pincode:</label>
          <input type="text" name="pincode" maxlength="6" required>
        </div>
      </fieldset>

      <!-- Account Details -->
      <fieldset>
        <legend>Account Details</legend>
        <div class="row">
          <label>Account Type:</label>
          <select name="accountType" required>
            <option value="">Select</option>
            <option>Savings Account</option>
            <option>Current Account</option>
            <option>Fixed Deposit</option>
          </select>
        </div>
        <div class="row">
          <label>Branch Name:</label>
          <input type="text" name="branchName" required>
        </div>
        <div class="row">
          <label>Initial Deposit Amount:</label>
          <input type="number" name="depositAmount" min="1000" required>
        </div>
      </fieldset>

      <!-- KYC Details -->
      <fieldset>
        <legend>KYC Details</legend>
        <div class="row">
          <label>Aadhar Number:</label>
          <input type="text" name="aadhar" maxlength="12" required>
        </div>
        <div class="row">
          <label>PAN Number:</label>
          <input type="text" name="pan" maxlength="10" required>
        </div>
        <div class="row">
          <label>Occupation:</label>
          <input type="text" name="occupation">
        </div>
      </fieldset>

      <!-- Nominee Details -->
      <fieldset>
        <legend>Nominee Details</legend>
        <div class="row">
          <label>Nominee Name:</label>
          <input type="text" name="nomineeName" required>
        </div>
        <div class="row">
          <label>Relationship:</label>
          <input type="text" name="relationship" required>
        </div>
        <div class="row">
          <label>Nominee Age:</label>
          <input type="number" name="nomineeAge" required>
        </div>
      </fieldset>

      <!-- Buttons -->
      <div class="buttons">
        <button type="submit" class="btn-primary">Create Account</button>
        <button type="reset" class="btn-secondary">Reset</button>
      </div>

    </form>
  </div>

  <script>
    // ✅ Validation before submission
    function validateForm() {
      const form = document.getElementById("accountForm");
      const requiredFields = form.querySelectorAll("[required]");
      for (let field of requiredFields) {
        if (!field.value.trim()) {
          alert("⚠️ Please fill all required details before submitting.");
          field.focus();
          return false;
        }
      }
      alert("✅ All details filled successfully!");
      return true;
    }
  </script>

</body>
</html>