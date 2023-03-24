using eCommerce.Domain.Abstractions.Audits;
using eCommerce.Domain.Abstractions.Paginations;

namespace eCommerce.Domain.Domains;

public class Brand : IFullAuditDomain, IPagedDomain
{
    public Guid Id { get; set; }
    public string Name { get; set; }
    public string LogoURL { get; set; }
    public string Description { get; set; }

    #region Full Audit Domain
    public bool Status { get; set; }
    public DateTime Created { get; set; }
    public DateTime Modified { get; set; }
    public bool IsDeleted { get; set; }
    #endregion

    #region Paged Domain
    public int TotalRows { get; set; }
    #endregion

}