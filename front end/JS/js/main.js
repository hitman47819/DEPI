const url = "https://api.adviceslip.com/advice";
const main_box = document.getElementById("main-box");

async function getAdvice() {
  const response = await fetch(url);
  const data = await response.json();

  main_box.innerHTML = `
    <span class="advive-id">ADVICE # ${data.slip.id}</span>
    <p class="advice my-3">
      ${data.slip.advice}
    </p>
    <div class="image my-0">
      <!-- Inline SVG for divider -->
      <svg xmlns="http://www.w3.org/2000/svg" width="444" height="16">
        <g fill="none" fill-rule="evenodd">
          <path fill="#4F5D74" d="M0 8h196v1H0zM248 8h196v1H248z"/>
          <g transform="translate(212)" fill="#CEE3E9">
            <rect width="6" height="16" rx="3"/>
            <rect x="14" width="6" height="16" rx="3"/>
          </g>
        </g>
      </svg>
    </div>
    <div
      class="random rounded-circle d-flex justify-content-center align-items-center my-0"
    >
      <div class="image-btn" id="random">
        <!-- Inline SVG for dice icon -->
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24">
          <path fill="#202733" d="M20 0H4C1.8 0 0 1.8 0 4v16c0 2.2 1.8 4 4 4h16c2.2 0 4-1.8 4-4V4c0-2.2-1.8-4-4-4zM6 10c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm6 6c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm6-6c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2z"/>
        </svg>
      </div>
    </div>
  `;

  const btn = document.getElementById("random");
  btn.addEventListener("click", getAdvice);
}

window.onload = getAdvice;
