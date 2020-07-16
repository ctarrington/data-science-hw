import warnings
warnings.filterwarnings('ignore')

import numpy as np
import pymc3 as pm
import arviz as az

def explore_heirarchical_binomial(data):
    min_category_id = np.min(data['category_id'])
    min_individual_id = np.min(data['individual_id'])

    data['category_id'] = data['category_id'] - min_category_id
    data['individual_id'] = data['individual_id'] - min_individual_id

    num_individuals = len(data)
    num_categories = len(np.unique(data['category_id']))

    print('num_individuals', num_individuals, 'num_categories', num_categories)

    individual_id = data['individual_id']
    category_id = data['category_id']


    with pm.Model() as model_h_o:
        p_overall = pm.Beta('p_overall', 1, 1)
        concentration_overall = pm.HalfNormal('concentration_overall', 10)
        p_category = pm.Beta('p_category',
                             alpha=p_overall*concentration_overall,
                             beta=(1.0-p_overall)*concentration_overall,
                             shape=num_categories)

        concentration_category = pm.HalfNormal('concentration_category', 10, shape=num_categories)

        p_individual = pm.Beta('p_individual',
                       alpha=p_category[category_id]*concentration_category[category_id],
                       beta=(1.0-p_category[category_id])*concentration_category[category_id],
                       shape=num_individuals)

        y = pm.Binomial('y', n=data['attempts'], p=p_individual[individual_id], observed=data['successes']) # likelihood p(y|θ)

        trace_h_o = pm.sample(2000)
        print(az.summary(trace_h_o))


    raw = data.copy(deep=True)
    raw.drop(columns=['individual', 'successes', 'attempts', 'individual_id'], inplace=True)
    raw.drop_duplicates(inplace=True)
    raw.sort_values(by='category_id', inplace=True)
    categories = raw['category'].to_numpy()
    print(categories)

    raw = data.copy(deep=True)
    raw.drop(columns=['category', 'category_id', 'successes', 'attempts'], inplace=True)
    raw.drop_duplicates(inplace=True)
    raw.sort_values(by='individual_id', inplace=True)
    individuals = raw['individual'].to_numpy()

    data_h_o = az.from_pymc3(
        trace=trace_h_o,
        # prior=prior,
        # posterior_predictive=posterior_predictive,
        model=model_h_o,
        coords={'category': categories, 'individual': individuals},
        dims={'p_category': ['category'], 'p_individual': ['individual']}
    )

    return (model_h_o, trace_h_o, data_h_o)


