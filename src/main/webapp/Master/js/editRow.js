document.addEventListener("DOMContentLoaded", function () {

    const inputs = document.querySelectorAll(".form-row input");

    inputs.forEach(input => {
        input.addEventListener("focus", () => {
            input.style.borderColor = "#0a5fa4";
        });
        input.addEventListener("blur", () => {
            input.style.borderColor = "#ccc";
        });
    });

});
