// ========== LOGIN ==========
document.addEventListener("DOMContentLoaded", function () {

  // Login
  const loginForm = document.getElementById('loginForm');
  if (loginForm) {
    loginForm.addEventListener('submit', function (e) {
      e.preventDefault();
      const email = document.getElementById('email').value;
      const senha = document.getElementById('senha').value;
      if (email && senha) {
        localStorage.setItem('usuarioLogado', email);
        alert('Login realizado com sucesso!');
        window.location.href = 'proposta.html';
      } else {
        alert('Preencha todos os campos!');
      }
    });
  }

  // Verificação de login nas páginas restritas
  if (!localStorage.getItem('usuarioLogado') && window.location.pathname.includes('proposta.html')) {
    alert('Faça login para acessar as propostas.');
    window.location.href = 'login.html';
  }

  // Logout
  const logoutBtn = document.getElementById('logout');
  if (logoutBtn) {
    logoutBtn.addEventListener('click', () => {
      localStorage.removeItem('usuarioLogado');
      window.location.href = 'login.html';
    });
  }

  // Proposta
  const formProposta = document.getElementById('formProposta');
  if (formProposta) {
    formProposta.addEventListener('submit', function(e){
      e.preventDefault();
      document.getElementById('mensagem').textContent = " Proposta enviada com sucesso!";
    });
  }

  // ========== GRÁFICO ==========
  const grafico = document.getElementById('graficoPedidos');
  if (grafico) {
    const ctx = grafico.getContext('2d');
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
        datasets: [{
          label: 'Pedidos Enviados',
          data: [10, 20, 15, 30, 25, 40, 50, 45, 35, 60, 70, 80],
          backgroundColor: 'rgba(46, 125, 50, 0.8)',
          borderColor: '#0a550a',
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            title: { display: true, text: 'Quantidade de Pedidos' }
          },
          x: {
            title: { display: true, text: 'Meses' }
          }
        }
      }
    });
  }

  // ========== MAPA ==========
  const mapaDiv = document.getElementById('map');
  if (mapaDiv) {
    const map = L.map('map').setView([-15.7801, -47.9292], 5);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contribuidores'
    }).addTo(map);

    const locais = {
      'Milho': [-23.5505, -46.6333],
      'Soja': [-19.9167, -43.9345],
      'Feijão': [-22.9035, -43.2096],
      'Café': [-15.7801, -47.9292]
    };

    let produtoMarker = null;

    function atualizarMapa(nomeProduto) {
      if (!locais[nomeProduto]) {
        alert("Produto não encontrado!");
        return;
      }

      const [lat, lng] = locais[nomeProduto];
      if (produtoMarker) map.removeLayer(produtoMarker);

      produtoMarker = L.marker([lat, lng]).addTo(map)
        .bindPopup(`<b> Produto: ${nomeProduto}</b><br>Localização atual.`)
        .openPopup();

      map.setView([lat, lng], 6);
    }

    const buscarBtn = document.getElementById('buscarBtn');
    if (buscarBtn) {
      buscarBtn.addEventListener('click', () => {
        const nomeProduto = document.getElementById('buscaProduto').value.trim();
        atualizarMapa(nomeProduto.charAt(0).toUpperCase() + nomeProduto.slice(1).toLowerCase());
      });
    }

    atualizarMapa('Milho');
  }

});
