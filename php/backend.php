<div id="backend" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="backendModalLabel" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h4 id="backendModalLabel">
          Hivent-Editor
        </h4>
      </div>
      <div class="modal-body">
          <div class="row">
            <div class="col-md-4">
              <h4>Hivents</h4>
            </div>
            <div class="col-md-8">
              <h4>Eigenschaften</h4>
            </div>
          </div>
          <div class="row">
            <div class="col-md-4">

              <!-- Hivent list -->
              <div class="form-group input-sm">
                  <div class="list-group">
                  <a href="#" class="list-group-item active">
                    Cras justo odio
                  </a>
                  <a href="#" class="list-group-item">Dapibus ac facilisis in</a>
                  <a href="#" class="list-group-item">Morbi leo risus</a>
                  <a href="#" class="list-group-item">Morbi leo risus</a>
                  <a href="#" class="list-group-item">Porta ac consectetur ac</a>
                  <a href="#" class="list-group-item">Porta ac consectetur ac</a>
                  <a href="#" class="list-group-item">Vestibulum at eros</a>
                  <a href="#" class="list-group-item">Vestibulum at eros</a>
                </div>
                <div class="input-group">
                  <span class="input-group-addon"><i class="fa fa-search"></i></span>
                  <input type="text" class="form-control" placeholder="Filtern...">
                </div>
              </div>

            </div>
            <div class="col-md-8">

              <!-- Edit area -->
              <form class="form-horizontal" role="form">
                <div class="form-group">
                  <label for="backendInputName" class="col-md-4 control-label">Name</label>
                  <div class="col-md-8">
                    <input id="backendInputName" class="form-control" placeholder="Name">
                  </div>
                </div>
                <div class="form-group">
                  <label for="backendInputCoords" class="col-md-4 control-label">Koordinaten</label>
                  <div class="col-md-4">
                    <input id="backendInputCoords" class="form-control" placeholder="Breite">
                  </div>
                  <div class="col-md-4">
                    <input class="form-control" placeholder="Länge">
                  </div>
                </div>
                <div class="form-group">
                  <label for="backendInputCoords" class="col-md-4 control-label">Datum</label>
                  <div class="col-md-4">
                    <input id="backendInputCoords" class="form-control" placeholder="Beginn">
                  </div>
                  <div class="col-md-4">
                    <input class="form-control" placeholder="Ende">
                  </div>
                </div>
                <div class="form-group">
                  <label for="backendInputText" class="col-md-4 control-label">Beschreibung</label>
                  <div class="col-md-8">
                    <textarea id="backendInputText" class="form-control" rows="3"></textarea>
                  </div>
                </div>
              </form>



            </div>
          </div>
      </div>
      <div class="modal-footer">
        <button type="button" data-dismiss="modal" class="btn btn-default" data-dismiss="modal">Abbrechen</button>
        <button type="button" class="btn btn-primary">Speichern</button>
      </div>
    </div>
  </div>
</div>
