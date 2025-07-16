{include file='globalheader.tpl'}
<div class="container mt-5">
    <div class="row justify-content-center">
        <div class="col-md-4">
            <div class="card shadow">
                <div class="card-body">
                    <h5 class="card-title text-center mb-4">Authentification à deux facteurs</h5>
                    {if $ShowTotpError}
                        <div class="alert alert-danger">Code TOTP invalide. Veuillez réessayer.</div>
                    {/if}
                    <form method="post">
                        <div class="mb-3">
                            <label for="totp_code" class="form-label">Code TOTP</label>
                            <input type="text" class="form-control" id="totp_code" name="totp_code" required autocomplete="one-time-code" autofocus>
                        </div>
                        <button type="submit" class="btn btn-primary w-100">Valider</button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
{include file='globalfooter.tpl'} 