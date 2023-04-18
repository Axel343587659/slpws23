
let modal = document.getElementById("myModal");
let btn = document.querySelector("#myBtn");
let span = document.getElementsByClassName("close")[0];

btn.addEventListener('click', function() {
  modal.style.display = "block";
})

window.onclick = function(event) {
  if (event.target == modal) {
    modal.style.display = "none";
  }
}
